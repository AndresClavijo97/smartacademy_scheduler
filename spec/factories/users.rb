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

    trait :with_preference do
      after(:create) do |user|
        create(:user_preference, user: user)
      end
    end

    trait :bello_student do
      after(:create) do |user|
        create(:user_preference, :bello_office, :a1_course, user: user)
      end
    end

    trait :medellin_student do
      after(:create) do |user|
        create(:user_preference, :medellin_office, :b1_course, user: user)
      end
    end

    trait :with_full_schedule do
      after(:create) do |user|
        create(:user_preference, :with_full_schedule, user: user)
      end
    end

    trait :automation_ready do
      email { "automation.#{Faker::Internet.username}@smart.edu.co" }
      schoolpack_username { "auto.#{Faker::Internet.username}" }
      
      after(:create) do |user|
        create(:user_preference, :a1_course, :bello_office, user: user)
      end
    end
  end
end
