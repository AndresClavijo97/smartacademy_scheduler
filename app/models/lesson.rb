class Lesson
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Constants
  DURATION_MINUTES = 90
  MAX_CLASSES_PER_DAY = 10
  
  field :lesson_number, type: Integer
  field :scheduled_date, type: Date
  field :start_time, type: Time
  field :end_time, type: Time
  field :completed, type: Mongoid::Boolean, default: false
  
  # Relationships
  belongs_to :course
  
  # Validations
  validates :lesson_number, presence: true
  validates :lesson_number, uniqueness: { scope: :course_id }
  
  # Indexes
  index({ course_id: 1, lesson_number: 1 })
  index({ scheduled_date: 1, start_time: 1 })
end
