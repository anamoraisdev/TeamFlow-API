require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_secure_password }

  it "requires a unique email, case-insensitively" do
    create(:user, email: "same@example.com")
    duplicate = build(:user, email: "SAME@example.com")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:email]).to be_present
  end

  it "rejects an invalid email format" do
    user = build(:user, email: "not-an-email")
    expect(user).not_to be_valid
  end

  it "rejects a password shorter than 8 characters" do
    user = build(:user, password: "short")
    expect(user).not_to be_valid
  end

  it "downcases the email before saving" do
    user = create(:user, email: "MixedCase@Example.com")
    expect(user.reload.email).to eq("mixedcase@example.com")
  end

  describe "#role_in" do
    it "returns the role for a team the user belongs to" do
      user = create(:user)
      team = create(:team)
      create(:team_membership, user: user, team: team, role: :admin)

      expect(user.role_in(team)).to eq("admin")
    end

    it "returns nil for a team the user does not belong to" do
      user = create(:user)
      team = create(:team)

      expect(user.role_in(team)).to be_nil
    end
  end
end
