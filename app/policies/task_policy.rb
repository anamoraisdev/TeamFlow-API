class TaskPolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member?
  end

  def create?
    allowed?(:task_manage)
  end

  def update?
    allowed?(:task_manage)
  end

  def destroy?
    allowed?(:task_manage)
  end

  private

  def team
    record.project.team
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(project: { team: :team_memberships }).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
