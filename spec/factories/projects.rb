FactoryBot.define do
  factory :project do
    team
    sequence(:name) { |n| "Project #{n}" }
    description { "A sample project" }
  end
end
