class TaskPolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member?
  end

  def create?
    member?
  end

  def update?
    member?
  end

  def destroy?
    member?
  end

  private

  def team
    record.project.team
  end

  def role
    user.role_in(team)
  end

  def member?
    role.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(project: { team: :team_memberships }).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
