class ProjectPolicy < ApplicationPolicy
  def index?
    member?
  end

  def show?
    member?
  end

  def create?
    allowed?(:project_manage)
  end

  def update?
    allowed?(:project_manage)
  end

  def destroy?
    allowed?(:project_manage)
  end

  private

  def team
    record.team
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(team: :team_memberships).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
