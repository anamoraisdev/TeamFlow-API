class MembershipPolicy < ApplicationPolicy
  def index?
    member?
  end

  def create?
    admin_or_owner?
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner? && record.role != "owner"
  end

  private

  def team
    record.team
  end

  def role
    user.role_in(team)
  end

  def member?
    role.present?
  end

  def admin_or_owner?
    role.in?(%w[admin owner])
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope
    end
  end
end
