class AuditLogPolicy < ApplicationPolicy
  def index?
    allowed?(:audit_log_view)
  end

  private

  def team
    record
  end
end
