require "rails_helper"

RSpec.describe TeamMembership, type: :model do
  it "has a valid factory" do
    expect(build(:team_membership)).to be_valid
  end

  it { is_expected.to define_enum_for(:role).with_values(member: 0, admin: 1, owner: 2) }

  it "does not allow the same user to join a team twice" do
    team = create(:team)
    user = create(:user)
    create(:team_membership, team: team, user: user)

    duplicate = build(:team_membership, team: team, user: user)

    expect(duplicate).not_to be_valid
  end

  it "does not allow a second owner on the same team" do
    team = create(:team)
    create(:team_membership, team: team, role: :owner)

    second_owner = build(:team_membership, team: team, role: :owner)

    expect(second_owner).not_to be_valid
    expect(second_owner.errors[:role]).to be_present
  end

  it "allows a different team to have its own owner" do
    create(:team_membership, role: :owner)
    other_team_owner = build(:team_membership, role: :owner)

    expect(other_team_owner).to be_valid
  end
end
