class NotificationPolicy < ApplicationPolicy
  def update?
    mine?
  end

  private

  def mine?
    record.user_id == user.id
  end
end
