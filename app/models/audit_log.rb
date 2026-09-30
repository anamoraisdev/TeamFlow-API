class AuditLog < ApplicationRecord
  belongs_to :team
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, presence: true
end
