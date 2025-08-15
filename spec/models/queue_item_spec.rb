require 'rails_helper'

RSpec.describe QueueItem, type: :model do
  let(:scheduler) { create(:scheduler) }
  let(:queue_item) do
    QueueItem.new(
      action: 'register_class',
      course_code: 'ENG001',
      lesson_number: 1,
      date: Date.current,
      start_time: '09:00',
      end_time: '10:30',
      user_schoolpack_username: 'test_user',
      user_schoolpack_password: 'test_pass'
    )
  end

  describe 'validations' do
    it 'validates presence of required fields' do
      item = QueueItem.new
      expect(item).not_to be_valid
      
      expect(item.errors[:action]).to include("can't be blank")
      expect(item.errors[:course_code]).to include("can't be blank")
      expect(item.errors[:lesson_number]).to include("can't be blank")
      expect(item.errors[:date]).to include("can't be blank")
    end

    it 'validates lesson_number is greater than 0' do
      queue_item.lesson_number = 0
      expect(queue_item).not_to be_valid
      expect(queue_item.errors[:lesson_number]).to include("must be greater than 0")
    end

    it 'validates attempts is non-negative' do
      queue_item.attempts = -1
      expect(queue_item).not_to be_valid
      expect(queue_item.errors[:attempts]).to include("must be greater than or equal to 0")
    end
  end

  describe 'state machine' do
    before { scheduler.queue_items << queue_item }

    it 'has pending as initial state' do
      expect(queue_item.status).to eq('pending')
      expect(queue_item).to be_pending
    end

    describe 'start_processing transition' do
      it 'transitions from pending to processing' do
        expect(queue_item).to be_pending
        
        queue_item.start_processing!
        
        expect(queue_item).to be_processing
        expect(queue_item.attempts).to eq(1)
        expect(queue_item.last_attempt_at).to be_present
      end

      it 'can transition from failed to processing' do
        queue_item.start_processing!
        queue_item.mark_failed!('Test error')
        
        expect(queue_item).to be_failed
        
        queue_item.start_processing!
        
        expect(queue_item).to be_processing
        expect(queue_item.attempts).to eq(2)
      end

      it 'increments attempts counter' do
        initial_attempts = queue_item.attempts
        
        queue_item.start_processing!
        
        expect(queue_item.attempts).to eq(initial_attempts + 1)
      end

      it 'updates last_attempt_at timestamp' do
        expect(queue_item.last_attempt_at).to be_nil
        
        queue_item.start_processing!
        
        expect(queue_item.last_attempt_at).to be_within(1.second).of(Time.current)
      end
    end

    describe 'mark_processed transition' do
      before { queue_item.start_processing! }

      it 'transitions from processing to processed' do
        expect(queue_item).to be_processing
        
        queue_item.mark_processed!
        
        expect(queue_item).to be_processed
        expect(queue_item.processed_at).to be_present
        expect(queue_item.error_message).to be_nil
      end

      it 'accepts smartacademia_id parameter' do
        smartacademia_id = 'SA_123_abc'
        
        queue_item.mark_processed!(smartacademia_id)
        
        expect(queue_item.smartacademia_id).to eq(smartacademia_id)
      end

      it 'clears error_message' do
        queue_item.error_message = 'Previous error'
        
        queue_item.mark_processed!
        
        expect(queue_item.error_message).to be_nil
      end

      it 'sets processed_at timestamp' do
        queue_item.mark_processed!
        
        expect(queue_item.processed_at).to be_within(1.second).of(Time.current)
      end
    end

    describe 'mark_failed transition' do
      before { queue_item.start_processing! }

      it 'transitions from processing to failed' do
        expect(queue_item).to be_processing
        
        queue_item.mark_failed!('Test error')
        
        expect(queue_item).to be_failed
        expect(queue_item.error_message).to eq('Test error')
        expect(queue_item.last_attempt_at).to be_present
      end

      it 'accepts error object' do
        error = StandardError.new('Connection failed')
        
        queue_item.mark_failed!(error)
        
        expect(queue_item.error_message).to eq('Connection failed')
      end

      it 'updates last_attempt_at timestamp' do
        old_timestamp = queue_item.last_attempt_at
        sleep(0.01) # Ensure time difference
        
        queue_item.mark_failed!('Test error')
        
        expect(queue_item.last_attempt_at).to be > old_timestamp
      end
    end

    describe 'retry transition' do
      before do
        queue_item.start_processing!
        queue_item.mark_failed!('Test error')
      end

      it 'transitions from failed to pending when can retry' do
        expect(queue_item).to be_failed
        expect(queue_item.attempts).to be < QueueItem::MAX_ATTEMPTS
        
        queue_item.retry!
        
        expect(queue_item).to be_pending
        expect(queue_item.error_message).to be_nil
      end

      it 'cannot retry when max attempts reached' do
        queue_item.attempts = QueueItem::MAX_ATTEMPTS
        
        expect { queue_item.retry! }.to raise_error(AASM::InvalidTransition)
      end

      it 'clears error_message on retry' do
        expect(queue_item.error_message).to be_present
        
        queue_item.retry!
        
        expect(queue_item.error_message).to be_nil
      end
    end
  end

  describe 'constants' do
    it 'defines MAX_ATTEMPTS' do
      expect(QueueItem::MAX_ATTEMPTS).to eq(3)
    end
  end

  describe '#can_retry?' do
    before { scheduler.queue_items << queue_item }

    it 'returns true when failed and under max attempts' do
      queue_item.start_processing!
      queue_item.mark_failed!('Test error')
      
      expect(queue_item.can_retry?).to be true
    end

    it 'returns false when not failed' do
      expect(queue_item.can_retry?).to be false
    end

    it 'returns false when max attempts reached' do
      queue_item.start_processing!
      queue_item.mark_failed!('Test error')
      queue_item.attempts = QueueItem::MAX_ATTEMPTS
      
      expect(queue_item.can_retry?).to be false
    end
  end

  describe 'embedded document behavior' do
    it 'is embedded in scheduler' do
      expect(queue_item.class.embedded_in_relations.keys).to include('scheduler')
    end

    it 'can be added to scheduler queue_items' do
      scheduler.queue_items << queue_item
      
      expect(scheduler.queue_items).to include(queue_item)
      expect(queue_item.scheduler).to eq(scheduler)
    end
  end
end