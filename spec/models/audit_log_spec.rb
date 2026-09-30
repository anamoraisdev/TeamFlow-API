require "rails_helper"

RSpec.describe AuditLog, type: :model do
  it "has a valid factory" do
    expect(build(:audit_log)).to be_valid
  end

  it { is_expected.to belong_to(:team) }
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:auditable).optional }
  it { is_expected.to validate_presence_of(:action) }

  it "does not require an actor (system-initiated entries)" do
    log = build(:audit_log, user: nil)
    expect(log).to be_valid
  end
end
