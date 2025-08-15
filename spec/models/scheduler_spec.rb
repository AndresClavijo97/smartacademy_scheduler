require 'rails_helper'

RSpec.describe Scheduler, type: :model do
  let(:user) { create(:user) }
  let(:course) { create(:course, code: 'ENG001', level: 'A1') }
  let(:start_date) { Date.current.next_week }

  describe 'validations' do
    let(:scheduler) { build(:scheduler, user: user, course_code: 'ENG001') }

    it 'validates presence of course_code' do
      scheduler.course_code = nil
      expect(scheduler).not_to be_valid
      expect(scheduler.errors[:course_code]).to include("can't be blank")
    end

    it 'validates presence of start_date' do
      scheduler.start_date = nil
      expect(scheduler).not_to be_valid
      expect(scheduler.errors[:start_date]).to include("can't be blank")
    end

    it 'validates inclusion of status' do
      scheduler.status = 'invalid_status'
      expect(scheduler).not_to be_valid
      expect(scheduler.errors[:status]).to include("is not included in the list")
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      scheduler = build(:scheduler, user: user)
      expect(scheduler.user).to eq(user)
    end
  end

  describe 'constants' do
    it 'defines scheduling constants correctly' do
      expect(Scheduler::LESSON_DURATION_MINUTES).to eq(90)
      expect(Scheduler::DAILY_CLASS_LIMIT).to eq(10)
      expect(Scheduler::START_HOUR).to eq(6)
      expect(Scheduler::END_HOUR).to eq(19)
      expect(Scheduler::LESSONS_PER_A1_COURSE).to eq(60)
    end
  end

  describe '.schedule' do
    before { course }

    context 'with valid parameters' do
      it 'creates a new scheduler and executes scheduling' do
        result = Scheduler.schedule(user: user, course_code: 'ENG001', start_date: start_date)
        
        expect(result[:success]).to be true
        expect(result[:course_code]).to eq('ENG001')
        expect(result[:total_lessons]).to eq(60)
        expect(Scheduler.count).to eq(1)
      end

      it 'uses next week as default start date' do
        result = Scheduler.schedule(user: user, course_code: 'ENG001')
        
        scheduler = Scheduler.last
        expect(scheduler.start_date).to eq(Date.current.next_week)
      end
    end

    context 'when course does not exist' do
      it 'fails with appropriate error' do
        result = Scheduler.schedule(user: user, course_code: 'INVALID')
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Curso INVALID no encontrado')
      end
    end

    context 'when course is not A1 level' do
      before { course.update(level: 'B1') }

      it 'fails with level error' do
        result = Scheduler.schedule(user: user, course_code: 'ENG001')
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Solo se pueden programar cursos de nivel A1')
      end
    end

    context 'when user already has the course scheduled' do
      before { create(:scheduler, user: user, course_code: 'ENG001', status: 'scheduled') }

      it 'fails with duplicate error' do
        result = Scheduler.schedule(user: user, course_code: 'ENG001')
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Usuario ya tiene el curso ENG001 programado')
      end
    end
  end

  describe '#execute_scheduling' do
    let(:scheduler) { build(:scheduler, user: user, course_code: 'ENG001', start_date: start_date) }

    before do
      course
      allow(scheduler).to receive(:navigate_and_select_course).and_return({ success: true })
    end

    it 'updates status to in_progress during execution' do
      expect(scheduler).to receive(:update_status).with('in_progress')
      expect(scheduler).to receive(:update_status).with('scheduled')
      
      scheduler.execute_scheduling
    end

    it 'validates course availability' do
      expect(scheduler).to receive(:validate_course_availability)
      scheduler.execute_scheduling
    end

    it 'generates lesson schedule with correct number of lessons' do
      result = scheduler.execute_scheduling
      
      expect(scheduler.scheduled_lessons.count).to eq(60)
      expect(result[:total_lessons]).to eq(60)
    end

    it 'creates smartacademia queue items' do
      result = scheduler.execute_scheduling
      
      expect(scheduler.queue_items.count).to eq(60)
      expect(result[:smartacademia_queue_size]).to eq(60)
    end

    context 'when navigation fails' do
      before do
        allow(scheduler).to receive(:navigate_and_select_course)
          .and_return({ success: false, error: 'Navigation failed' })
      end

      it 'handles error and sets status to failed' do
        result = scheduler.execute_scheduling
        
        expect(result[:success]).to be false
        expect(result[:error]).to include('Navigation failed')
        expect(scheduler.status).to eq('failed')
      end
    end
  end

  describe '#generate_daily_time_slots' do
    let(:scheduler) { build(:scheduler, user: user, course_code: 'ENG001') }

    it 'generates correct number of daily slots' do
      slots = scheduler.send(:generate_daily_time_slots)
      
      expect(slots.length).to be <= 10
      expect(slots.length).to be > 0
    end

    it 'generates slots with correct duration' do
      slots = scheduler.send(:generate_daily_time_slots)
      
      slots.each do |slot|
        start_time = Time.parse(slot[:start_time])
        end_time = Time.parse(slot[:end_time])
        duration = ((end_time - start_time) / 60).to_i
        
        expect(duration).to eq(90)
      end
    end

    it 'starts at correct hour' do
      slots = scheduler.send(:generate_daily_time_slots)
      first_slot = slots.first
      
      expect(first_slot[:start_time]).to eq('06:00')
    end

    it 'respects daily class limit' do
      slots = scheduler.send(:generate_daily_time_slots)
      
      expect(slots.length).to be <= Scheduler::DAILY_CLASS_LIMIT
    end
  end

  describe '#calculate_available_schedules' do
    let(:scheduler) { build(:scheduler, user: user, course_code: 'ENG001', start_date: start_date) }

    it 'generates schedules for multiple days' do
      available_slots = scheduler.send(:calculate_available_schedules)
      
      expect(available_slots.length).to be > 10
      dates = available_slots.map { |slot| slot[:date] }.uniq
      expect(dates.length).to be > 1
    end

    it 'only includes available slots' do
      available_slots = scheduler.send(:calculate_available_schedules)
      
      available_slots.each do |slot|
        expect(slot[:available]).to be true
      end
    end
  end

  describe '#statistics' do
    let(:scheduler) { create(:scheduler, user: user, course_code: 'ENG001') }

    before do
      scheduler.scheduled_lessons = [
        { lesson_number: 1, status: 'completed' },
        { lesson_number: 2, status: 'scheduled' },
        { lesson_number: 3, status: 'scheduled' }
      ]
      scheduler.smartacademia_queue = [
        { status: 'pending' },
        { status: 'processed' },
        { status: 'pending' }
      ]
      scheduler.save
    end

    it 'returns correct statistics' do
      stats = scheduler.statistics
      
      expect(stats[:total_lessons]).to eq(3)
      expect(stats[:completed_lessons]).to eq(1)
      expect(stats[:pending_lessons]).to eq(2)
      expect(stats[:queue_pending]).to eq(2)
      expect(stats[:queue_processed]).to eq(1)
    end
  end

  describe '.pending_schedules' do
    before do
      Scheduler.destroy_all # Clear previous data
      create(:scheduler, status: 'pending')
      create(:scheduler, status: 'scheduled')
      create(:scheduler, status: 'pending')
    end

    it 'returns only pending schedules' do
      pending = Scheduler.pending_schedules
      
      expect(pending.count).to eq(2)
      pending.each do |scheduler|
        expect(scheduler.status).to eq('pending')
      end
    end
  end

  describe '.active_schedules' do
    before do
      Scheduler.destroy_all # Clear previous data
      create(:scheduler, status: 'scheduled')
      create(:scheduler, status: 'in_progress')
      create(:scheduler, status: 'completed')
      create(:scheduler, status: 'failed')
    end

    it 'returns only active schedules' do
      active = Scheduler.active_schedules
      
      expect(active.count).to eq(2)
      statuses = active.map(&:status)
      expect(statuses).to match_array(%w[scheduled in_progress])
    end
  end

  describe '.for_user' do
    let(:other_user) { create(:user) }

    before do
      create(:scheduler, user: user)
      create(:scheduler, user: user)
      create(:scheduler, user: other_user)
    end

    it 'returns schedules only for the specified user' do
      user_schedules = Scheduler.for_user(user)
      
      expect(user_schedules.count).to eq(2)
      user_schedules.each do |scheduler|
        expect(scheduler.user).to eq(user)
      end
    end
  end

  describe '#process_smartacademia_queue' do
    let(:scheduler) { create(:scheduler, user: user, course_code: 'ENG001') }

    before do
      scheduler.smartacademia_queue = [
        { status: 'pending', lesson_number: 1 },
        { status: 'processed', lesson_number: 2 },
        { status: 'pending', lesson_number: 3 }
      ]
      scheduler.save
    end

    it 'processes only pending queue items' do
      scheduler.process_smartacademia_queue
      
      processed_items = scheduler.smartacademia_queue.select { |item| item[:status] == 'processed' }
      expect(processed_items.length).to eq(3)
    end

    it 'adds processed_at timestamp to processed items' do
      scheduler.process_smartacademia_queue
      
      scheduler.smartacademia_queue.each do |item|
        if item[:lesson_number] != 2 # Was not already processed
          expect(item[:processed_at]).to be_present
        end
      end
    end
  end
end