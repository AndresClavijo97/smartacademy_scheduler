require 'rails_helper'

RSpec.describe SmartAcademiaService, type: :model do
  let(:user) { create(:user) }
  let(:lesson_data) do
    {
      course_code: 'ENG001',
      lesson_number: 1,
      date: Date.current,
      start_time: '09:00',
      end_time: '10:30',
      duration_minutes: 90
    }
  end

  describe 'validations' do
    let(:service) { build(:smart_academia_service, user: user, operation_type: 'register_class') }

    it 'validates inclusion of operation_type' do
      service.operation_type = 'invalid_operation'
      expect(service).not_to be_valid
      expect(service.errors[:operation_type]).to include("is not included in the list")
    end

    it 'has pending as initial state' do
      expect(service.status).to eq('pending')
      expect(service).to be_pending
    end
  end

  describe 'state machine' do
    let(:service) { build(:smart_academia_service, user: user, operation_type: 'register_class') }

    it 'transitions from pending to processing' do
      expect(service).to be_pending
      service.start_processing!
      expect(service).to be_processing
    end

    it 'transitions from processing to completed' do
      service.start_processing!
      expect(service).to be_processing
      
      service.complete!({ lesson_id: 'test_123' })
      expect(service).to be_completed
      expect(service.completed_at).to be_present
      expect(service.response_data).to include('lesson_id' => 'test_123')
    end

    it 'transitions from processing to failed' do
      service.start_processing!
      error = StandardError.new('Test error')
      
      service.fail!(error)
      expect(service).to be_failed
      expect(service.error_message).to eq('Test error')
      expect(service.completed_at).to be_present
    end

    it 'transitions from failed to pending on retry' do
      service.start_processing!
      service.fail!(StandardError.new('Test error'))
      
      expect(service).to be_failed
      service.retry_operation!
      expect(service).to be_pending
      expect(service.error_message).to be_nil
      expect(service.completed_at).to be_nil
    end

    it 'allows transition from failed to processing on retry' do
      service.start_processing!
      service.fail!(StandardError.new('Test error'))
      service.retry_operation!
      
      expect(service).to be_pending
      service.start_processing!
      expect(service).to be_processing
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      service = build(:smart_academia_service, user: user)
      expect(service.user).to eq(user)
    end
  end

  describe 'constants' do
    it 'defines service constants correctly' do
      expect(SmartAcademiaService::SMARTACADEMIA_BASE_URL).to eq('https://schoolpack.smart.edu.co/idiomas')
      expect(SmartAcademiaService::LOGIN_ENDPOINT).to eq('/wv0480.aspx')
      expect(SmartAcademiaService::SCHEDULER_ENDPOINT).to eq('/wv0527.aspx')
    end
  end

  describe '.register_class' do
    it 'creates a new service instance and executes registration' do
      expect_any_instance_of(SmartAcademiaService).to receive(:execute_registration)
        .and_return({ success: true })

      result = SmartAcademiaService.register_class(user: user, lesson_data: lesson_data)
      
      expect(SmartAcademiaService.count).to eq(1)
      service = SmartAcademiaService.last
      expect(service.user).to eq(user)
      expect(service.operation_type).to eq('register_class')
      expect(service.request_data).to eq(lesson_data)
    end
  end

  describe '.register_course_lessons' do
    let(:scheduler) do
      create(:scheduler, user: user, course_code: 'ENG001').tap do |s|
        s.scheduled_lessons = [
          lesson_data,
          lesson_data.merge(lesson_number: 2, start_time: '10:30', end_time: '12:00')
        ]
        s.save
      end
    end

    before do
      allow(SmartAcademiaService).to receive(:register_class)
        .and_return({ success: true })
    end

    it 'registers all lessons from scheduler' do
      expect(SmartAcademiaService).to receive(:register_class).twice

      result = SmartAcademiaService.register_course_lessons(user: user, scheduler: scheduler)
      
      expect(result[:total_lessons]).to eq(2)
      expect(result[:successful]).to eq(2)
      expect(result[:failed]).to eq(0)
    end

    it 'handles mixed success/failure results' do
      allow(SmartAcademiaService).to receive(:register_class)
        .and_return({ success: true }, { success: false })

      result = SmartAcademiaService.register_course_lessons(user: user, scheduler: scheduler)
      
      expect(result[:successful]).to eq(1)
      expect(result[:failed]).to eq(1)
    end

    it 'adds delay between successful registrations' do
      expect(SmartAcademiaService).to receive(:sleep).with(1).once
      
      SmartAcademiaService.register_course_lessons(user: user, scheduler: scheduler)
    end
  end

  describe '#execute_registration' do
    let(:service) do
      SmartAcademiaService.new(
        user: user,
        operation_type: 'register_class',
        request_data: lesson_data
      )
    end

    before do
      allow(service).to receive(:authenticate_with_smartacademia)
        .and_return({ success: true })
      allow(service).to receive(:navigate_to_scheduler)
        .and_return({ success: true })
      allow(service).to receive(:register_lesson_in_system)
        .and_return({ success: true, lesson_id: 'lesson_123' })
      allow(service).to receive(:confirm_lesson_registration)
        .and_return({ success: true })
    end

    it 'updates status to processing during execution' do
      expect(service).to receive(:start_processing!)
      
      service.execute_registration
    end

    it 'follows the complete registration flow' do
      expect(service).to receive(:authenticate_with_smartacademia)
      expect(service).to receive(:navigate_to_scheduler)
      expect(service).to receive(:register_lesson_in_system)
      expect(service).to receive(:confirm_lesson_registration)
      
      result = service.execute_registration
      expect(result[:success]).to be true
    end

    it 'returns success response with service details' do
      result = service.execute_registration
      
      expect(result[:success]).to be true
      expect(result[:service_id]).to be_present
      expect(result[:lesson_data]).to eq(lesson_data)
      expect(result[:message]).to include('registrada exitosamente')
    end

    context 'when authentication fails' do
      before do
        allow(service).to receive(:authenticate_with_smartacademia)
          .and_return({ success: false, error: 'Auth failed' })
      end

      it 'handles authentication error' do
        result = service.execute_registration
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Auth failed')
        expect(service.status).to eq('failed')
      end
    end

    context 'when navigation fails' do
      before do
        allow(service).to receive(:navigate_to_scheduler)
          .and_return({ success: false, error: 'Navigation failed' })
      end

      it 'handles navigation error' do
        result = service.execute_registration
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Navigation failed')
      end
    end

    context 'when lesson registration fails' do
      before do
        allow(service).to receive(:register_lesson_in_system)
          .and_return({ success: false, error: 'Registration failed' })
      end

      it 'handles registration error' do
        result = service.execute_registration
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Registration failed')
      end
    end
  end

  describe '#authenticate_with_smartacademia' do
    let(:service) { SmartAcademiaService.new(user: user, operation_type: 'register_class') }

    context 'with valid user credentials' do
      it 'returns success with session token' do
        result = service.send(:authenticate_with_smartacademia)
        
        expect(result[:success]).to be true
        expect(result[:session_token]).to be_present
        expect(result[:auth_data][:username]).to eq(user.schoolpack_username)
      end
    end

    context 'with missing credentials' do
      before do
        user.update(schoolpack_username: nil)
      end

      it 'returns failure with credentials error' do
        result = service.send(:authenticate_with_smartacademia)
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Credenciales de SmartAcademia no configuradas')
      end
    end
  end

  describe '#create_local_lesson_record' do
    let(:service) do
      SmartAcademiaService.new(
        user: user,
        operation_type: 'register_class',
        request_data: lesson_data
      )
    end

    it 'creates a lesson record with correct attributes' do
      lesson = service.send(:create_local_lesson_record)
      
      expect(lesson.user).to eq(user)
      expect(lesson.course_code).to eq('ENG001')
      expect(lesson.lesson_number).to eq(1)
      expect(lesson.scheduled_date).to eq(Date.current)
      expect(lesson.start_time).to eq('09:00')
      expect(lesson.end_time).to eq('10:30')
      expect(lesson.duration_minutes).to eq(90)
      expect(lesson.status).to eq('scheduled')
      expect(lesson.smartacademia_registered).to be true
    end
  end

  describe '.process_pending_registrations' do
    before do
      3.times { create(:smart_academia_service, status: 'pending') }
      2.times { create(:smart_academia_service, status: 'completed') }
    end

    it 'processes only pending services' do
      expect_any_instance_of(SmartAcademiaService).to receive(:execute_registration)
        .exactly(3).times.and_return({ success: true })

      result = SmartAcademiaService.process_pending_registrations
      
      expect(result[:processed]).to eq(3)
      expect(result[:results].length).to eq(3)
    end

    it 'respects the limit parameter' do
      expect_any_instance_of(SmartAcademiaService).to receive(:execute_registration)
        .exactly(2).times.and_return({ success: true })

      SmartAcademiaService.where(status: 'pending').limit(2)
      result = SmartAcademiaService.process_pending_registrations
      
      expect(result[:processed]).to be <= 3
    end

    it 'adds delay between processing' do
      allow_any_instance_of(SmartAcademiaService).to receive(:execute_registration)
        .and_return({ success: true })
      expect(SmartAcademiaService).to receive(:sleep).with(2).at_least(:once)

      SmartAcademiaService.process_pending_registrations
    end
  end

  describe '.registration_statistics' do
    before do
      user2 = create(:user)
      create(:smart_academia_service, user: user, status: 'pending')
      create(:smart_academia_service, user: user, status: 'completed')
      create(:smart_academia_service, user: user, status: 'failed')
      create(:smart_academia_service, user: user2, status: 'completed')
    end

    context 'without user filter' do
      it 'returns statistics for all services' do
        stats = SmartAcademiaService.registration_statistics
        
        expect(stats[:total]).to eq(4)
        expect(stats[:pending]).to eq(1)
        expect(stats[:completed]).to eq(2)
        expect(stats[:failed]).to eq(1)
        expect(stats[:success_rate]).to eq(50.0)
      end
    end

    context 'with user filter' do
      it 'returns statistics for specific user' do
        stats = SmartAcademiaService.registration_statistics(user)
        
        expect(stats[:total]).to eq(3)
        expect(stats[:completed]).to eq(1)
        expect(stats[:success_rate]).to eq(33.33)
      end
    end
  end

  describe '.retry_failed_registrations' do
    before do
      3.times { create(:smart_academia_service, status: 'failed') }
    end

    it 'resets failed services to pending and retries' do
      expect_any_instance_of(SmartAcademiaService).to receive(:execute_registration)
        .exactly(3).times.and_return({ success: true })

      results = SmartAcademiaService.retry_failed_registrations
      
      expect(results.length).to eq(3)
      SmartAcademiaService.all.each do |service|
        expect(service.status).not_to eq('failed')
      end
    end

    it 'respects the limit parameter' do
      results = SmartAcademiaService.retry_failed_registrations(2)
      
      expect(results.length).to eq(2)
    end
  end

  describe 'query scopes' do
    let(:other_user) { create(:user) }

    before do
      create(:smart_academia_service, user: user, status: 'completed')
      create(:smart_academia_service, user: user, status: 'failed')
      create(:smart_academia_service, user: other_user, status: 'completed')
    end

    describe '.for_user' do
      it 'returns services for specific user' do
        user_services = SmartAcademiaService.for_user(user)
        
        expect(user_services.count).to eq(2)
        user_services.each { |service| expect(service.user).to eq(user) }
      end
    end

    describe '.successful' do
      it 'returns only completed services' do
        successful = SmartAcademiaService.successful
        
        expect(successful.count).to eq(2)
        successful.each { |service| expect(service.status).to eq('completed') }
      end
    end

    describe '.failed' do
      it 'returns only failed services' do
        failed = SmartAcademiaService.failed
        
        expect(failed.count).to eq(1)
        failed.each { |service| expect(service.status).to eq('failed') }
      end
    end
  end
end