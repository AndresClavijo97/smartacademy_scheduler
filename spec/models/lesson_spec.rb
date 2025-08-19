require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'validations' do
    let(:lesson) { build(:lesson) }

    it 'is valid with all required attributes' do
      expect(lesson).to be_valid
    end

    it 'requires number presence' do
      lesson.number = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors[:number]).to include("can't be blank")
    end

    it 'requires level presence' do
      lesson.level = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors[:level]).to include("can't be blank")
    end

    it 'requires kind presence' do
      lesson.kind = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors[:kind]).to include("can't be blank")
    end

    it 'requires description presence' do
      lesson.description = nil
      expect(lesson).not_to be_valid
      expect(lesson.errors[:description]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      user = create(:user)
      lesson = create(:lesson, user: user)

      expect(lesson.user).to eq(user)
    end
  end

  describe 'constants' do
    it 'defines correct business hours' do
      expect(Lesson::BUSINESS_START_HOUR).to eq(6)
      expect(Lesson::BUSINESS_END_HOUR).to eq(19)
      expect(Lesson::BUSINESS_END_MINUTE).to eq(30)
    end

    it 'defines correct lesson duration' do
      expect(Lesson::DEFAULT_DURATION_MINUTES).to eq(90)
    end

    it 'defines maximum classes per day' do
      expect(Lesson::MAX_CLASSES_PER_DAY).to eq(10)
    end

    it 'defines lesson types with required status' do
      expect(Lesson::TYPES[:intro][:required]).to be true
      expect(Lesson::TYPES[:class][:required]).to be true
      expect(Lesson::TYPES[:quiz_unit][:required]).to be false
      expect(Lesson::TYPES[:smart_zone][:required]).to be false
      expect(Lesson::TYPES[:exam_prep][:required]).to be true
      expect(Lesson::TYPES[:final_exam][:required]).to be true
    end
  end

  describe 'lesson types and structure' do
    context 'intro lessons' do
      let(:intro_lesson) { build(:lesson, :intro_lesson) }

      it 'creates intro lesson with correct attributes' do
        expect(intro_lesson.kind).to eq('intro')
        expect(intro_lesson.number).to be_between(1, 8)
        expect(intro_lesson.mandatory?).to be true
      end
    end

    context 'class lessons' do
      let(:class_lesson) { build(:lesson, :class_lesson) }

      it 'creates class lesson with correct attributes' do
        expect(class_lesson.kind).to eq('class')
        expect(class_lesson.number).to be_between(9, 96)
        expect(class_lesson.mandatory?).to be true
      end
    end

    context 'quiz unit lessons' do
      let(:quiz_lesson) { build(:lesson, :quiz_unit) }

      it 'creates quiz unit with correct attributes' do
        expect(quiz_lesson.kind).to eq('quiz_unit')
        expect(quiz_lesson.mandatory?).to be false
        expect(quiz_lesson.optional?).to be true
      end
    end

    context 'smart zone lessons' do
      let(:smart_zone_lesson) { build(:lesson, :smart_zone) }

      it 'creates smart zone with correct attributes' do
        expect(smart_zone_lesson.kind).to eq('smart_zone')
        expect(smart_zone_lesson.mandatory?).to be false
        expect(smart_zone_lesson.optional?).to be true
      end
    end

    context 'exam preparation lessons' do
      let(:exam_prep_lesson) { build(:lesson, :exam_prep) }

      it 'creates exam prep lesson with correct attributes' do
        expect(exam_prep_lesson.kind).to eq('exam_prep')
        expect(exam_prep_lesson.number).to eq(97)
        expect(exam_prep_lesson.mandatory?).to be true
      end
    end

    context 'final exam lessons' do
      let(:final_exam_lesson) { build(:lesson, :final_exam) }

      it 'creates final exam with correct attributes' do
        expect(final_exam_lesson.kind).to eq('final_exam')
        expect(final_exam_lesson.number).to eq(98)
        expect(final_exam_lesson.mandatory?).to be true
      end
    end
  end

  describe 'level progression' do
    context 'A1 level lessons' do
      let(:a1_lesson) { build(:lesson, level: 'A1', number: 50) }

      it 'creates A1 lesson with correct number range' do
        expect(a1_lesson.level).to eq('A1')
        expect(a1_lesson.number).to be_between(1, 98)
      end
    end

    context 'A2 level lessons' do
      let(:a2_lesson) { build(:lesson, :a2_level) }

      it 'creates A2 lesson with correct number range' do
        expect(a2_lesson.level).to eq('A2')
        expect(a2_lesson.number).to be_between(99, 196)
      end
    end

    context 'B1 level lessons' do
      let(:b1_lesson) { build(:lesson, :b1_level) }

      it 'creates B1 lesson with correct number range' do
        expect(b1_lesson.level).to eq('B1')
        expect(b1_lesson.number).to be_between(197, 294)
      end
    end
  end

  describe 'state machine' do
    let(:lesson) { create(:lesson) }

    describe 'initial state' do
      it 'starts with pending status' do
        expect(lesson).to have_state(:pending)
      end

      it 'has pending as initial state' do
        new_lesson = build(:lesson)
        expect(new_lesson.status).to eq('pending')
      end
    end

    describe 'state transitions' do
      context 'when lesson is pending' do
        let(:pending_lesson) { create(:lesson, status: 'pending') }

        it 'allows schedule event' do
          expect(pending_lesson).to allow_event(:schedule)
        end

        it 'allows cancel event' do
          expect(pending_lesson).to allow_event(:cancel)
        end

        it 'does not allow start event' do
          expect(pending_lesson).not_to allow_event(:start)
        end

        it 'does not allow complete event' do
          expect(pending_lesson).not_to allow_event(:complete)
        end

        it 'transitions to scheduled on schedule' do
          pending_lesson.schedule
          expect(pending_lesson).to have_state(:scheduled)
        end

        it 'transitions to cancelled on cancel' do
          pending_lesson.cancel
          expect(pending_lesson).to have_state(:cancelled)
        end
      end

      context 'when lesson is scheduled' do
        let(:scheduled_lesson) { create(:lesson, status: 'scheduled') }

        it 'has scheduled state' do
          expect(scheduled_lesson).to have_state(:scheduled)
        end

        it 'allows start event' do
          expect(scheduled_lesson).to allow_event(:start)
        end

        it 'allows complete event' do
          expect(scheduled_lesson).to allow_event(:complete)
        end

        it 'allows cancel event' do
          expect(scheduled_lesson).to allow_event(:cancel)
        end

        it 'transitions to in_progress on start' do
          scheduled_lesson.start
          expect(scheduled_lesson).to have_state(:in_progress)
        end

        it 'transitions to completed on complete' do
          scheduled_lesson.complete
          expect(scheduled_lesson).to have_state(:completed)
        end

        it 'transitions to cancelled on cancel' do
          scheduled_lesson.cancel
          expect(scheduled_lesson).to have_state(:cancelled)
        end
      end

      context 'when lesson is in_progress' do
        let(:in_progress_lesson) { create(:lesson, status: 'in_progress') }

        it 'has in_progress state' do
          expect(in_progress_lesson).to have_state(:in_progress)
        end

        it 'allows complete event' do
          expect(in_progress_lesson).to allow_event(:complete)
        end

        it 'allows cancel event' do
          expect(in_progress_lesson).to allow_event(:cancel)
        end

        it 'does not allow start event' do
          expect(in_progress_lesson).not_to allow_event(:start)
        end

        it 'transitions to completed on complete' do
          in_progress_lesson.complete
          expect(in_progress_lesson).to have_state(:completed)
        end

        it 'transitions to cancelled on cancel' do
          in_progress_lesson.cancel
          expect(in_progress_lesson).to have_state(:cancelled)
        end
      end

      context 'when lesson is completed' do
        let(:completed_lesson) { create(:lesson, status: 'completed') }

        it 'has completed state' do
          expect(completed_lesson).to have_state(:completed)
        end

        it 'does not allow any events' do
          expect(completed_lesson).not_to allow_event(:start)
          expect(completed_lesson).not_to allow_event(:complete)
          expect(completed_lesson).not_to allow_event(:cancel)
          expect(completed_lesson).not_to allow_event(:reschedule)
        end

        it 'is a final state' do
          expect(completed_lesson).not_to allow_transition_to(:pending)
          expect(completed_lesson).not_to allow_transition_to(:scheduled)
          expect(completed_lesson).not_to allow_transition_to(:cancelled)
        end
      end

      context 'when lesson is cancelled' do
        let(:cancelled_lesson) { create(:lesson, status: 'cancelled') }

        it 'has cancelled state' do
          expect(cancelled_lesson).to have_state(:cancelled)
        end

        it 'allows reschedule event' do
          expect(cancelled_lesson).to allow_event(:reschedule)
        end

        it 'does not allow other events' do
          expect(cancelled_lesson).not_to allow_event(:start)
          expect(cancelled_lesson).not_to allow_event(:complete)
          expect(cancelled_lesson).not_to allow_event(:cancel)
        end

        it 'transitions to scheduled on reschedule' do
          cancelled_lesson.reschedule
          expect(cancelled_lesson).to have_state(:scheduled)
        end
      end

      context 'when lesson has no_show status' do
        let(:no_show_lesson) { create(:lesson, status: 'no_show') }

        it 'has no_show state' do
          expect(no_show_lesson).to have_state(:no_show)
        end

        it 'allows reschedule event' do
          expect(no_show_lesson).to allow_event(:reschedule)
        end

        it 'transitions to scheduled on reschedule' do
          no_show_lesson.reschedule
          expect(no_show_lesson).to have_state(:scheduled)
        end
      end
    end

    describe 'state machine validation' do
      it 'defines all expected states' do
        expected_states = [ :pending, :scheduled, :in_progress, :completed, :cancelled, :no_show ]
        lesson_states = Lesson.aasm.states.map(&:name)

        expected_states.each do |state|
          expect(lesson_states).to include(state)
        end
      end

      it 'defines all expected events' do
        expected_events = [ :schedule, :start, :complete, :cancel, :reschedule ]
        lesson_events = Lesson.aasm.events.map(&:name)

        expected_events.each do |event|
          expect(lesson_events).to include(event)
        end
      end
    end
  end

  describe 'instance methods' do
    let(:mandatory_lesson) { create(:lesson, :class_lesson) }
    let(:optional_lesson) { create(:lesson, :quiz_unit) }

    describe '#mandatory?' do
      it 'returns true for mandatory lesson types' do
        expect(mandatory_lesson.mandatory?).to be true
      end

      it 'returns false for optional lesson types' do
        expect(optional_lesson.mandatory?).to be false
      end
    end

    describe '#optional?' do
      it 'returns false for mandatory lesson types' do
        expect(mandatory_lesson.optional?).to be false
      end

      it 'returns true for optional lesson types' do
        expect(optional_lesson.optional?).to be true
      end
    end
  end

  describe 'indexes' do
    it 'has proper indexes defined' do
      index_keys = Lesson.index_specifications.map(&:key)
      expect(index_keys).to include({ user_id: 1, scheduled_at: 1 })
      expect(index_keys).to include({ course_code: 1, number: 1 })
      expect(index_keys).to include({ scheduled_at: 1, start_time: 1 })
      expect(index_keys).to include({ status: 1, scheduled_at: 1 })
    end
  end

  describe 'office locations' do
    let(:bello_lesson) { build(:lesson, office: 'Bello') }
    let(:medellin_lesson) { build(:lesson, :medellin_office) }

    it 'supports Bello office' do
      expect(bello_lesson.office).to eq('Bello')
    end

    it 'supports Medellin office' do
      expect(medellin_lesson.office).to eq('Medellin')
    end
  end
end
