class TeamBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :created_at

  view :with_role do
    field :role do |team, options|
      options[:current_user]&.role_in(team)
    end
  end
end
