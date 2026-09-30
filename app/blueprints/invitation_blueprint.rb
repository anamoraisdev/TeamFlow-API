class InvitationBlueprint < Blueprinter::Base
  identifier :id

  fields :team_id, :invited_email, :role, :status, :expires_at, :created_at

  association :invited_by, blueprint: UserBlueprint
end
