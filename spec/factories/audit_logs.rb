FactoryBot.define do
  factory :audit_log do
    team
    user
    action { "task.created" }
  end
end
