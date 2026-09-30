require "rails_helper"

RSpec.describe InvitationPolicy do
  subject(:policy) { described_class.new(user, invitation) }

  let(:team) { create(:team) }
  let(:invitation) { create(:invitation, team: team, invited_email: "invitee@example.com") }

  context "when the user is a plain member" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :member) }

    it { is_expected.not_to permit_action(:index) }
    it { is_expected.not_to permit_action(:create) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context "when the user is an admin" do
    let(:user) { create(:user) }

    before { create(:team_membership, team: team, user: user, role: :admin) }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when the user is the invited person" do
    let(:user) { create(:user, email: "invitee@example.com") }

    it { is_expected.to permit_action(:accept) }
    it { is_expected.to permit_action(:decline) }
  end

  context "when the user is not the invited person" do
    let(:user) { create(:user, email: "someone-else@example.com") }

    before { create(:team_membership, team: team, user: user, role: :owner) }

    it { is_expected.not_to permit_action(:accept) }
    it { is_expected.not_to permit_action(:decline) }
  end
end
