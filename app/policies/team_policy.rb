class TeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    member?
  end

  def create?
    true
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    owner?
  end

  private

  def role
    user.role_in(record)
  end

  def member?
    role.present?
  end

  def admin_or_owner?
    role.in?(%w[admin owner])
  end

  def owner?
    role == "owner"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:team_memberships).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
