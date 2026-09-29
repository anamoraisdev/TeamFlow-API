class ProjectBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :description, :team_id, :created_at
end
