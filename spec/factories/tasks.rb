FactoryBot.define do
  factory :task do
    project
    sequence(:title) { |n| "Task #{n}" }
    description { "A sample task" }
    status { :pending }
    priority { :medium }
    due_date { 1.week.from_now.to_date }
    assignee { nil }
  end
end
