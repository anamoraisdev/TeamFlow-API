require "rails_helper"

RSpec.describe Invitation, type: :model do
  it "has a valid factory" do
    expect(build(:invitation)).to be_valid
  end

  it { is_expected.to belong_to(:team) }
  it { is_expected.to belong_to(:invited_by) }
  it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1) }
  it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, declined: 2, revoked: 3, expired: 4) }
  it { is_expected.to validate_presence_of(:invited_email) }

  it "generates a unique token on create" do
    invitation = create(:invitation)
    expect(invitation.token).to be_present
  end

  it "defaults expires_at to 7 days from now" do
    invitation = create(:invitation)
    expect(invitation.expires_at).to be_within(1.minute).of(7.days.from_now)
  end

  it "downcases the invited email" do
    invitation = create(:invitation, invited_email: "MixedCase@Example.com")
    expect(invitation.invited_email).to eq("mixedcase@example.com")
  end

  it "rejects a second pending invitation to the same email on the same team" do
    team = create(:team)
    create(:invitation, team: team, invited_email: "dup@example.com")

    duplicate = build(:invitation, team: team, invited_email: "dup@example.com")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:invited_email]).to be_present
  end

  it "allows a new pending invitation once the previous one is no longer pending" do
    team = create(:team)
    first = create(:invitation, team: team, invited_email: "again@example.com")
    first.revoke!

    second = build(:invitation, team: team, invited_email: "again@example.com")

    expect(second).to be_valid
  end

  describe "#accept!" do
    it "creates a membership with the invited role and marks the invitation accepted" do
      team = create(:team)
      invitation = create(:invitation, team: team, role: :admin)
      user = create(:user)

      invitation.accept!(user)

      expect(team.team_memberships.find_by(user: user).role).to eq("admin")
      expect(invitation.reload).to be_accepted
    end

    it "raises when the invitation is no longer pending" do
      invitation = create(:invitation)
      invitation.revoke!

      expect { invitation.accept!(create(:user)) }.to raise_error(Invitation::AlreadyProcessedError)
    end

    it "raises when the invitation has expired" do
      invitation = create(:invitation, expires_at: 1.hour.ago)

      expect { invitation.accept!(create(:user)) }.to raise_error(Invitation::ExpiredError)
    end

    it "handles a concurrent double-accept without creating a duplicate membership" do
      team = create(:team)
      invitation = create(:invitation, team: team)
      user = create(:user)

      copy_one = Invitation.find(invitation.id)
      copy_two = Invitation.find(invitation.id)

      copy_one.accept!(user)

      expect { copy_two.accept!(user) }.to raise_error(ActiveRecord::StaleObjectError)
      expect(team.team_memberships.where(user: user).count).to eq(1)
      expect(invitation.reload).to be_accepted
    end
  end

  describe "#decline!" do
    it "marks the invitation declined" do
      invitation = create(:invitation)

      invitation.decline!

      expect(invitation.reload).to be_declined
    end

    it "raises when already processed" do
      invitation = create(:invitation)
      invitation.decline!

      expect { invitation.decline! }.to raise_error(Invitation::AlreadyProcessedError)
    end
  end

  describe "#revoke!" do
    it "marks the invitation revoked" do
      invitation = create(:invitation)

      invitation.revoke!

      expect(invitation.reload).to be_revoked
    end
  end
end
