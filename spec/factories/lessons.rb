FactoryBot.define do
  factory :lesson do
    association :user
    level { 'A1' }
    number { 1 }
    description { 'Introducción al inglés básico' }
    kind { 'intro' }
    office { 'Bello' }
    scheduled_at { Date.current }
    start_time { DateTime.current.change(hour: 8, min: 0) }
    end_time { DateTime.current.change(hour: 9, min: 30) }
    status { 'pending' }
    html_row_id { "lesson_#{number}" }

    trait :intro_lesson do
      kind { 'intro' }
      number { rand(1..8) }
      description { "Introducción #{number}" }
    end

    trait :class_lesson do
      kind { 'class' }
      number { rand(9..96) }
      description { "Clase #{number}" }
    end

    trait :quiz_unit do
      kind { 'quiz_unit' }
      number { rand(1..98) }
      description { "Quiz Unit #{number}" }
    end

    trait :smart_zone do
      kind { 'smart_zone' }
      number { rand(1..98) }
      description { "Smart Zone #{number}" }
    end

    trait :exam_prep do
      kind { 'exam_prep' }
      number { 97 }
      description { "Preparación Examen Final" }
    end

    trait :final_exam do
      kind { 'final_exam' }
      number { 98 }
      description { "Examen Final" }
    end

    trait :scheduled do
      status { 'scheduled' }
    end

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :no_show do
      status { 'no_show' }
    end

    trait :a2_level do
      level { 'A2' }
      number { rand(99..196) }
    end

    trait :b1_level do
      level { 'B1' }
      number { rand(197..294) }
    end

    trait :medellin_office do
      office { 'Medellin' }
    end
  end
end
