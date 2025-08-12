FactoryBot.define do
  factory :user_preference do
    office { UserPreference::VALID_OFFICES.sample }
    course { UserPreference::VALID_COURSES.sample }
    lesson { Faker::Educator.course_name }
    schedule { { 'monday' => ['09:00', '10:00'], 'wednesday' => ['14:00', '15:00'] } }
    credentials { { 'username' => Faker::Internet.username, 'password' => Faker::Internet.password } }
    user_id { Faker::Alphanumeric.alphanumeric(number: 24) }

    trait :bello_office do
      office { 'Bello' }
    end

    trait :medellin_office do
      office { 'Medellin' }
    end

    trait :a1_course do
      course { 'A1' }
    end

    trait :b1_course do
      course { 'B1' }
    end

    trait :with_full_schedule do
      schedule do
        {
          'monday' => ['09:00', '10:00', '14:00', '15:00'],
          'tuesday' => ['10:00', '11:00'],
          'wednesday' => ['09:00', '10:00'],
          'thursday' => ['14:00', '15:00'],
          'friday' => ['16:00', '17:00']
        }
      end
    end

    trait :empty_schedule do
      schedule { {} }
    end
  end
end
