class TaskBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :description, :status, :priority, :due_date, :project_id, :created_at

  association :assignee, blueprint: UserBlueprint
end
