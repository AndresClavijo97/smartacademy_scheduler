FactoryBot.define do
  factory :course do
    code { 'ENG001' }
    title { "English A1 Course" }
    description { "Basic English course for beginners" }
    level { "A1" }
    active { true }
    total_lessons { 60 }
    
    trait :a2_level do
      code { 'ENG002' }
      title { "English A2 Course" }
      level { "A2" }
    end
    
    trait :inactive do
      active { false }
    end
  end
end
