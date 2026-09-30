require "rails_helper"

RSpec.describe Notification, type: :model do
  it "has a valid factory" do
    expect(build(:notification)).to be_valid
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:title) }

  describe ".unread" do
    it "only returns notifications without a read_at" do
      unread = create(:notification, read_at: nil)
      create(:notification, read_at: Time.current)

      expect(Notification.unread).to eq([ unread ])
    end
  end

  describe "#mark_read!" do
    it "sets read_at" do
      notification = create(:notification, read_at: nil)

      notification.mark_read!

      expect(notification.read_at).to be_present
    end

    it "is a no-op if already read" do
      read_at = 1.day.ago
      notification = create(:notification, read_at: read_at)

      notification.mark_read!

      expect(notification.read_at).to be_within(1.second).of(read_at)
    end
  end
end
