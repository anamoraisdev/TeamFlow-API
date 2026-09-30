# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # Overridden by subclasses to resolve the team a role should be checked
  # against for the record/action being authorized. Returns nil when the
  # action isn't scoped to an existing team (e.g. Team#create).
  def team
    nil
  end

  def role_in_team
    return @role_in_team if defined?(@role_in_team)

    @role_in_team = team && user.role_in(team)
  end

  def member?
    role_in_team.present?
  end

  def allowed?(ability)
    Permissions.allowed?(role_in_team, ability)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
