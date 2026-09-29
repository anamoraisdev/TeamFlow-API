FactoryBot.define do
  factory :team_membership do
    team
    user
    role { :member }
  end
end
