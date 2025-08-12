FactoryBot.define do
  factory :user_preference do
    office { "MyString" }
    course { "MyString" }
    lesson { "MyString" }
    schedule { "" }
    credentials { "" }
  end
end
