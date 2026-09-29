class TeamMembershipBlueprint < Blueprinter::Base
  identifier :id

  fields :role, :team_id, :created_at

  association :user, blueprint: UserBlueprint
end
