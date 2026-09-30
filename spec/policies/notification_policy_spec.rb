require "rails_helper"

RSpec.describe NotificationPolicy do
  subject(:policy) { described_class.new(user, notification) }

  let(:owner) { create(:user) }
  let(:notification) { create(:notification, user: owner) }

  context "when the user owns the notification" do
    let(:user) { owner }

    it { is_expected.to permit_action(:update) }
  end

  context "when the user does not own the notification" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:update) }
  end
end
