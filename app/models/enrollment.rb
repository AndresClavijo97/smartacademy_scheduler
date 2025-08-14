class Enrollment
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :enrolled_at, type: DateTime, default: -> { Time.current }
  field :completed_at, type: DateTime
  field :progress, type: Integer, default: 0
  
  # Relationships
  belongs_to :user
  belongs_to :course
  
  # Validations
  validates :user_id, uniqueness: { scope: :course_id }
  validates :progress, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  
  # Indexes
  index({ user_id: 1, course_id: 1 })
  index({ enrolled_at: 1 })
  index({ completed_at: 1 })
end
