require "rails_helper"

RSpec.describe ProjectPolicy do
  subject(:policy) { described_class.new(user, project) }

  let(:team) { create(:team) }
  let(:project) { create(:project, team: team) }

  context "when the user is a member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when the user is an admin" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :admin) }

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the user does not belong to the team" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
  end
end
