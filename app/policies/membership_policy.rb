class MembershipPolicy < ApplicationPolicy
  def index?
    member?
  end

  def create?
    allowed?(:membership_manage)
  end

  def update?
    allowed?(:membership_manage)
  end

  def destroy?
    allowed?(:membership_manage) && record.role != "owner"
  end

  private

  def team
    record.team
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
    end
  end
end
