require "rails_helper"

RSpec.describe AuditLogPolicy do
  subject(:policy) { described_class.new(user, team) }

  let(:team) { create(:team) }

  context "when the user is a plain member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.not_to permit_action(:index) }
  end

  context "when the user is an admin" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :admin) }

    it { is_expected.to permit_action(:index) }
  end

  context "when the user is the owner" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :owner) }

    it { is_expected.to permit_action(:index) }
  end

  context "when the user does not belong to the team" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:index) }
  end
end
