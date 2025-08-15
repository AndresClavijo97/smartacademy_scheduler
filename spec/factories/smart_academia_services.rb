FactoryBot.define do
  factory :smart_academia_service do
    association :user
    operation_type { 'register_class' }
    status { 'pending' }
    
    request_data do
      {
        course_code: 'ENG001',
        lesson_number: 1,
        date: Date.current,
        start_time: '09:00',
        end_time: '10:30',
        duration_minutes: 90
      }
    end
    
    response_data { {} }
    
    trait :processing do
      status { 'processing' }
    end
    
    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
      response_data do
        {
          lesson_number: 1,
          course_code: 'ENG001',
          date: Date.current,
          status: 'confirmed',
          smartacademia_id: 'SA_123456789_abcdef12'
        }
      end
    end
    
    trait :failed do
      status { 'failed' }
      error_message { 'Registration failed due to server error' }
      completed_at { Time.current }
    end
    
    trait :login_operation do
      operation_type { 'login' }
      request_data do
        {
          username: 'test_user',
          password: 'test_password'
        }
      end
    end
    
    trait :schedule_operation do
      operation_type { 'schedule_class' }
    end
  end
end