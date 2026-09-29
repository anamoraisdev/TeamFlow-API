class ProjectPolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member?
  end

  def create?
    admin_or_owner?
  end

  def update?
    admin_or_owner?
  end

  def destroy?
    admin_or_owner?
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
      scope.joins(team: :team_memberships).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
