require "rails_helper"

RSpec.describe Team, type: :model do
  it "has a valid factory" do
    expect(build(:team)).to be_valid
  end

  it { is_expected.to validate_presence_of(:name) }

  describe "#owner" do
    it "returns the user with the owner membership" do
      team = create(:team)
      owner = create(:user)
      create(:team_membership, team: team, user: owner, role: :owner)
      create(:team_membership, team: team, user: create(:user), role: :member)

      expect(team.owner).to eq(owner)
    end
  end

  it "destroys dependent projects and memberships when destroyed" do
    team = create(:team)
    create(:team_membership, team: team)
    project = create(:project, team: team)
    create(:task, project: project)

    expect { team.destroy }.to change(TeamMembership, :count).by(-1)
      .and change(Project, :count).by(-1)
      .and change(Task, :count).by(-1)
  end
end
