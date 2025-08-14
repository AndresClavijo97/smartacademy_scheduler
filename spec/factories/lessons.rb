FactoryBot.define do
  factory :lesson do
    course { nil }
    lesson_number { 1 }
    scheduled_date { "2025-08-13" }
    start_time { "2025-08-13 20:52:24" }
    end_time { "2025-08-13 20:52:24" }
    completed { false }
  end
end
