class Lesson
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  # Constants generales
  DEFAULT_DURATION_MINUTES = 90
  MAX_CLASSES_PER_DAY = 10
  MIN_CLASSES_PER_DAY = 1

  # Horarios de negocio
  START_HOUR = 6
  END_HOUR = 19
  END_MINUTE = 30

  # Tipos de lecciones con información de si son requeridas
  TYPES = {
    intro: { required: true, pattern: /intro/i },
    class: { required: true, pattern: /clase/i },
    quiz_unit: { required: false, pattern: /quiz\s*unit/i },
    smart_zone: { required: false, pattern: /smart\s*zone/i },
    exam_prep: { required: true, pattern: /preparaci[oó]n.*examen/i },
    final_exam: { required: true, pattern: /examen\s*final/i }
  }.freeze

  # Campos
  field :level, type: String
  field :number, type: Integer
  field :description, type: String
  field :status, type: String
  field :office, type: String
  field :scheduled_at, type: Date
  field :start_time, type: Time
  field :end_time, type: Time
  field :kind, type: String # Tipo de lección: intro, clase, quiz_unit, smart_zone, exam_prep, final_exam
  field :html_row_id, type: String

  # Relationships
  belongs_to :user, class_name: "User", inverse_of: :lessons

  # Validaciones
  validates :number, :level, :kind, :description, presence: true

  # Validación personalizada para horarios válidos
  # validate :valid_time_range
  # validate :valid_hours

  # Scopes
  scope :by_date_range, ->(start_date, end_date) { where(scheduled_at: start_date..end_date) }
  scope :today, -> { where(scheduled_at: Date.current) }
  scope :upcoming, -> { where(scheduled_at: Date.current..) }
  scope :available_classes_by_day, ->(limit) { where(status: "pending", :kind.in => [ "class", "quiz_unit" ]).limit(limit) }

  # Indexes
  index({ user_id: 1, scheduled_at: 1 })
  index({ course_code: 1, number: 1 })
  index({ scheduled_at: 1, start_time: 1 })
  index({ status: 1, scheduled_at: 1 })

  # State machine
  aasm column: :status do
    state :pending, initial: true
    state :scheduled, :in_progress, :completed, :cancelled, :no_show

    event :schedule do
      transitions from: :pending, to: :scheduled
    end

    event :start do
      transitions from: :scheduled, to: :in_progress
    end

    event :complete do
      transitions from: [ :scheduled, :in_progress ], to: :completed
    end

    event :cancel do
      transitions from: [ :pending, :scheduled, :in_progress ], to: :cancelled
    end

    event :reschedule do
      transitions from: [ :cancelled, :no_show ], to: :scheduled
    end
  end

  # Métodos de instancia
  def mandatory?
    TYPES[kind.to_sym][:required]
  end

  def optional?
    !mandatory?
  end

  def time_range
    "#{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  private

  def valid_time_range
    return if end_time <= start_time

    errors.add(:end_time, "debe ser posterior a la hora de inicio")
  end

  def valid_hours
    return if start_time.hour >= START_HOUR && start_time.hour < END_HOUR &&
              end_time.hour >= START_HOUR &&
              (end_time.hour < END_HOUR || (end_time.hour == END_HOUR && end_time.min <= END_MINUTE))

    errors.add(:start_time, "debe estar entre #{START_HOUR}:00 AM y #{END_HOUR}:#{END_MINUTE} PM")
    errors.add(:end_time, "debe estar entre #{START_HOUR}:00 AM y #{END_HOUR}:#{END_MINUTE} PM")
  end
end
