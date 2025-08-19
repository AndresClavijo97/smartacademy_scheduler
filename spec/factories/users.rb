FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    schoolpack_username { Faker::Internet.username(specifier: 5..8) }
    schoolpack_password { 'schoolpack123' }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :automation_ready do
      email { "automation.#{Faker::Internet.username}@smart.edu.co" }
      schoolpack_username { "auto.#{Faker::Internet.username}" }
    end
  end
end
