require "rails_helper"

RSpec.describe TeamPolicy do
  subject(:policy) { described_class.new(user, team) }

  let(:team) { create(:team) }

  context "when the user is not a member of the team" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
  end

  context "when the user is a member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when the user is an admin" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :admin) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when the user is the owner" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :owner) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "Scope" do
    it "only returns teams the user belongs to" do
      user = create(:user)
      own_team = create(:team)
      create(:team_membership, team: own_team, user: user)
      create(:team) # unrelated team

      scope = TeamPolicy::Scope.new(user, Team.all).resolve

      expect(scope).to contain_exactly(own_team)
    end
  end
end
