require "rails_helper"

RSpec.describe MembershipPolicy do
  subject(:policy) { described_class.new(user, membership) }

  let(:team) { create(:team) }
  let(:target_user) { create(:user) }
  let(:membership) { create(:team_membership, team: team, user: target_user, role: :member) }

  context "when the user is a plain member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.to permit_action(:index) }
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

  context "when trying to remove the team owner" do
    let(:user) { create(:user) }
    let(:membership) { create(:team_membership, team: team, user: target_user, role: :owner) }

    before { create(:team_membership, team: team, user: user, role: :admin) }

    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when the user does not belong to the team" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
  end
end
