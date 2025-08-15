FactoryBot.define do
  factory :scheduler do
    association :user
    course_code { 'ENG001' }
    start_date { Date.current.next_week }
    status { 'pending' }
    
    trait :with_lessons do
      after(:build) do |scheduler|
        scheduler.scheduled_lessons.build(
          lesson_number: 1,
          course_code: scheduler.course_code,
          date: scheduler.start_date,
          start_time: '09:00',
          end_time: '10:30',
          duration_minutes: 90,
          status: 'scheduled'
        )
        
        scheduler.scheduled_lessons.build(
          lesson_number: 2,
          course_code: scheduler.course_code,
          date: scheduler.start_date + 1.day,
          start_time: '09:00',
          end_time: '10:30',
          duration_minutes: 90,
          status: 'scheduled'
        )
        
        scheduler.scheduled_lessons.each do |lesson|
          scheduler.queue_items.build(
            action: 'register_class',
            course_code: lesson.course_code,
            lesson_number: lesson.lesson_number,
            date: lesson.date,
            start_time: lesson.start_time,
            end_time: lesson.end_time,
            status: 'pending'
          )
        end
      end
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
    
    trait :failed do
      status { 'failed' }
      last_error { 'Sample error message' }
    end
  end
end