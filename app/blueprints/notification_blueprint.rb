class NotificationBlueprint < Blueprinter::Base
  identifier :id

  fields :category, :title, :body, :payload, :read_at, :created_at
end
