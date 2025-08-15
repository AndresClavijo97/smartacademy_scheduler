class LessonType
  include Mongoid::Document
  include Mongoid::Timestamps

  # Constantes para tipos de lecciones (basado en análisis completo de screenshots)
  LESSON_TYPES = {
    intro: 'intro',
    clase: 'clase', 
    quiz_unit: 'quiz_unit',
    smart_zone: 'smart_zone',
    exam_prep: 'exam_prep',
    final_exam: 'final_exam'
  }.freeze

  # Campos
  field :name, type: String
  field :code, type: String
  field :description, type: String
  field :is_mandatory, type: Boolean, default: true
  field :duration_minutes, type: Integer, default: 90
  field :active, type: Boolean, default: true

  # Relaciones
  has_many :lessons, dependent: :destroy

  # Validaciones
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, inclusion: { in: LESSON_TYPES.values }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :mandatory, -> { where(is_mandatory: true) }
  scope :optional, -> { where(is_mandatory: false) }
  scope :active, -> { where(active: true) }

  # Indexes
  index({ code: 1 }, { unique: true })
  index({ is_mandatory: 1, active: 1 })

  # Métodos de clase para crear tipos predefinidos (basado en screenshots completos)
  def self.create_default_types
    type_definitions = {
      intro: {
        name: 'Introducción',
        description: 'Clases introductorias (INTRO 1-8)',
        is_mandatory: true,
        duration_minutes: 90
      },
      clase: {
        name: 'Clase Principal',
        description: 'Clases principales del curso (CLASE 1-72)',
        is_mandatory: true,
        duration_minutes: 90
      },
      quiz_unit: {
        name: 'Quiz Units',
        description: 'Evaluaciones opcionales distribuidas (8 por nivel)',
        is_mandatory: false,
        duration_minutes: 90
      },
      smart_zone: {
        name: 'Smart Zone',
        description: 'Actividades complementarias opcionales (8 por nivel)',
        is_mandatory: false,
        duration_minutes: 90
      },
      exam_prep: {
        name: 'Preparación Examen Final',
        description: 'Clase preparatoria para examen final',
        is_mandatory: true,
        duration_minutes: 90
      },
      final_exam: {
        name: 'Examen Final',
        description: 'Evaluación final del nivel',
        is_mandatory: true,
        duration_minutes: 90
      }
    }

    type_definitions.each do |key, attributes|
      find_or_create_by(code: LESSON_TYPES[key]) do |lesson_type|
        lesson_type.assign_attributes(attributes.merge(code: LESSON_TYPES[key]))
      end
    end
  end

  def mandatory?
    is_mandatory
  end

  def optional?
    !is_mandatory
  end
end