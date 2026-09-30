FactoryBot.define do
  factory :invitation do
    team
    invited_by factory: :user
    sequence(:invited_email) { |n| "invitee#{n}@example.com" }
    role { :member }
  end
end
