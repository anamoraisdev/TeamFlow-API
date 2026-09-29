require "rails_helper"

RSpec.describe TaskPolicy do
  subject(:policy) { described_class.new(user, task) }

  let(:team) { create(:team) }
  let(:project) { create(:project, team: team) }
  let(:task) { create(:task, project: project) }

  context "when the user is a plain member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the user does not belong to the project's team" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:show) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
  end
end
