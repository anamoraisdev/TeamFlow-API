require "rails_helper"

RSpec.describe Permissions do
  describe ".allowed?" do
    it "grants member abilities to every role" do
      Permissions::MEMBER_ABILITIES.each do |ability|
        expect(Permissions.allowed?(:member, ability)).to be true
        expect(Permissions.allowed?(:admin, ability)).to be true
        expect(Permissions.allowed?(:owner, ability)).to be true
      end
    end

    it "grants admin-tier abilities to admin and owner but not member" do
      admin_only = Permissions::ADMIN_ABILITIES - Permissions::MEMBER_ABILITIES
      expect(admin_only).not_to be_empty

      admin_only.each do |ability|
        expect(Permissions.allowed?(:member, ability)).to be false
        expect(Permissions.allowed?(:admin, ability)).to be true
        expect(Permissions.allowed?(:owner, ability)).to be true
      end
    end

    it "grants owner-only abilities exclusively to owner" do
      owner_only = Permissions::OWNER_ABILITIES - Permissions::ADMIN_ABILITIES
      expect(owner_only).not_to be_empty

      owner_only.each do |ability|
        expect(Permissions.allowed?(:member, ability)).to be false
        expect(Permissions.allowed?(:admin, ability)).to be false
        expect(Permissions.allowed?(:owner, ability)).to be true
      end
    end

    it "denies every ability when there is no role (not a team member)" do
      Permissions::OWNER_ABILITIES.each do |ability|
        expect(Permissions.allowed?(nil, ability)).to be false
      end
    end

    it "accepts string roles and abilities, not just symbols" do
      expect(Permissions.allowed?("owner", "team_destroy")).to be true
      expect(Permissions.allowed?("member", "team_destroy")).to be false
    end
  end
end
