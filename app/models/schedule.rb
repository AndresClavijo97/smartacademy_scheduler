class Schedule
  include Mongoid::Document
  
  # Constantes del sistema de horarios (basado en análisis real)
  LESSON_DURATION_MINUTES = 90
  DAILY_CLASS_LIMIT = 10
  START_HOUR = 6  # 6:00 AM
  END_HOUR = 19   # 7:30 PM (última clase termina a 9:00 PM)
  
  # Campos del documento
  field :user_id, type: BSON::ObjectId
  field :course_code, type: String
  field :start_date, type: Date
  field :status, type: String, default: 'pending'
  field :last_error, type: String
  field :created_at, type: Time, default: -> { Time.current }
  field :updated_at, type: Time, default: -> { Time.current }
  
  # Relaciones
  belongs_to :user
  embeds_many :scheduled_lessons
  
  # Validaciones
  validates :course_code, presence: true
  validates :start_date, presence: true
  
  # Índices
  index({ user_id: 1, course_code: 1 })
  index({ status: 1, created_at: -1 })
end