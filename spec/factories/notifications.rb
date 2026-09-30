FactoryBot.define do
  factory :notification do
    user
    category { "task_assigned" }
    title { "You were assigned to a task" }
    body { "In project Sample Project." }
  end
end
