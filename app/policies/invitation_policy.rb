class InvitationPolicy < ApplicationPolicy
  def index?
    allowed?(:invitation_manage)
  end

  def create?
    allowed?(:invitation_manage)
  end

  def destroy?
    allowed?(:invitation_manage)
  end

  def accept?
    mine?
  end

  def decline?
    mine?
  end

  private

  def team
    record.team
  end

  def mine?
    record.invited_email.casecmp?(user.email)
  end
end
