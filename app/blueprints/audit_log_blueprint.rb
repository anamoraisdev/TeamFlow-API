class AuditLogBlueprint < Blueprinter::Base
  identifier :id

  fields :action, :auditable_type, :auditable_id, :metadata, :created_at

  association :user, blueprint: UserBlueprint
end
