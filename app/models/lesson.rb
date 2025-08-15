class Lesson
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM
  
  # Constants para estados
  SCHEDULED = 'scheduled'.freeze
  IN_PROGRESS = 'in_progress'.freeze
  COMPLETED = 'completed'.freeze
  CANCELLED = 'cancelled'.freeze
  NO_SHOW = 'no_show'.freeze

  LESSON_STATES = [
    SCHEDULED,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED,
    NO_SHOW
  ].freeze

  # Constants generales
  DEFAULT_DURATION_MINUTES = 90
  MAX_CLASSES_PER_DAY = 10
  
  # Campos
  field :lesson_number, type: Integer
  field :course_code, type: String
  field :scheduled_date, type: Date
  field :start_time, type: String # "14:30" format
  field :end_time, type: String   # "16:00" format
  field :duration_minutes, type: Integer, default: DEFAULT_DURATION_MINUTES
  field :status, type: String, default: SCHEDULED
  field :notes, type: String
  field :smartpack_lesson_id, type: String # ID de la lección en SmartAcademia
  
  # Relationships
  belongs_to :user
  belongs_to :course, optional: true
  belongs_to :lesson_type
  
  # Validaciones
  validates :lesson_number, presence: true
  validates :course_code, presence: true
  validates :scheduled_date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, inclusion: { in: LESSON_STATES }
  validates :duration_minutes, numericality: { greater_than: 0 }
  
  # Validación personalizada para horarios válidos
  validate :valid_time_range
  validate :valid_business_hours
  
  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_date_range, ->(start_date, end_date) { where(scheduled_date: start_date..end_date) }
  scope :mandatory, -> { joins(:lesson_type).where('lesson_types.is_mandatory' => true) }
  scope :optional, -> { joins(:lesson_type).where('lesson_types.is_mandatory' => false) }
  scope :for_course, ->(course_code) { where(course_code: course_code) }
  scope :today, -> { where(scheduled_date: Date.current) }
  scope :upcoming, -> { where(scheduled_date: Date.current..) }
  
  # Indexes
  index({ user_id: 1, scheduled_date: 1 })
  index({ course_code: 1, lesson_number: 1 })
  index({ scheduled_date: 1, start_time: 1 })
  index({ status: 1, scheduled_date: 1 })

  # State machine
  aasm column: :status do
    state :scheduled, initial: true
    state :in_progress
    state :completed
    state :cancelled
    state :no_show

    event :start do
      transitions from: :scheduled, to: :in_progress
    end

    event :complete do
      transitions from: [:scheduled, :in_progress], to: :completed
    end

    event :cancel do
      transitions from: [:scheduled, :in_progress], to: :cancelled
    end

    event :mark_no_show do
      transitions from: :scheduled, to: :no_show
    end

    event :reschedule do
      transitions from: [:cancelled, :no_show], to: :scheduled
    end
  end

  # Métodos de instancia
  def mandatory?
    lesson_type.mandatory?
  end

  def optional?
    lesson_type.optional?
  end

  def duration_in_hours
    duration_minutes / 60.0
  end

  def time_range
    "#{start_time} - #{end_time}"
  end

  def full_description
    "#{lesson_type.name} #{lesson_number} - #{course_code}"
  end

  private

  def valid_time_range
    return unless start_time.present? && end_time.present?
    
    start_parsed = Time.parse(start_time) rescue nil
    end_parsed = Time.parse(end_time) rescue nil
    
    return unless start_parsed && end_parsed
    
    errors.add(:end_time, 'debe ser posterior a la hora de inicio') if end_parsed <= start_parsed
  end

  def valid_business_hours
    return unless start_time.present? && end_time.present?
    
    start_parsed = Time.parse(start_time) rescue nil
    end_parsed = Time.parse(end_time) rescue nil
    
    return unless start_parsed && end_parsed
    
    business_start = Time.parse('06:00')
    business_end = Time.parse('19:30')
    
    errors.add(:start_time, 'debe estar entre 6:00 AM y 7:30 PM') if start_parsed.hour < 6 || start_parsed.hour >= 19
    errors.add(:end_time, 'debe estar entre 6:00 AM y 7:30 PM') if end_parsed.hour < 6 || end_parsed.hour > 19 || (end_parsed.hour == 19 && end_parsed.min > 30)
  end
end
