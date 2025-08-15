class ScheduledLesson
  include Mongoid::Document
  
  # Este documento está embebido en Scheduler
  embedded_in :schedule
  
  # Campos
  field :lesson_number, type: Integer
  field :course_code, type: String
  field :date, type: Date
  field :start_time, type: String
  field :end_time, type: String
  field :duration_minutes, type: Integer, default: 90
  field :status, type: String
  
  # Validaciones
  validates :lesson_number, presence: true, numericality: { greater_than: 0 }
  validates :course_code, presence: true
  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  
  # Método
end