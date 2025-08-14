class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Constants
  LESSON_DURATION_MINUTES = 90
  TOTAL_LESSONS_A1 = 60
  AVAILABLE_LEVELS = %w[A1 A2 B1 B2 C1 C2].freeze
  
  field :title, type: String
  field :description, type: String
  field :level, type: String, default: 'A1'
  field :active, type: Mongoid::Boolean, default: true
  field :total_lessons, type: Integer, default: TOTAL_LESSONS_A1
  
  # Relationships
  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
  
  # Validations
  validates :title, presence: true
  validates :level, presence: true, inclusion: { in: AVAILABLE_LEVELS }
  validates :total_lessons, presence: true, numericality: { greater_than: 0 }
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_level, ->(level) { where(level: level) }
  
  # Indexes
  index({ level: 1, active: 1 })
  index({ created_at: 1 })
  
  # Methods
  def create_lessons!
    return if lessons.count >= total_lessons
    
    (lessons.count + 1..total_lessons).each do |lesson_number|
      lessons.create!(lesson_number: lesson_number)
    end
  end
end
