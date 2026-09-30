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
    allowed?(:team_update)
  end

  def destroy?
    allowed?(:team_destroy)
  end

  private

  def team
    record
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:team_memberships).where(team_memberships: { user_id: user.id }).distinct
    end
  end
end
