class Course
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Constants para niveles y progresión (basado en análisis de screenshots completos)
  LESSON_DURATION_MINUTES = 90
  TOTAL_LESSONS_A1 = 98 # Número máximo real confirmado por screenshots
  INTRO_LESSONS_A1 = 8 # INTRO 1-8
  MAIN_LESSONS_A1 = 72 # CLASE 1-72 (aprox. 9 bloques de 8 clases)
  QUIZ_UNITS_A1 = 8 # Múltiples QUIZ UNITS distribuidos
  SMART_ZONE_A1 = 8 # Múltiples SMART ZONE distribuidos
  EXAM_LESSONS_A1 = 2 # PREPARACIÓN + EXAMEN FINAL
  AVAILABLE_LEVELS = {
    a1: 'A1',
    a2: 'A2', 
    b1: 'B1',
    b2: 'B2',
    c1: 'C1',
    c2: 'C2'
  }.freeze
  
  # Estructura real del nivel A1 basada en screenshots
  A1_STRUCTURE = {
    intro_classes: INTRO_LESSONS_A1,     # INTRO 1-8 (clases 1-8)
    main_classes: MAIN_LESSONS_A1,       # CLASE 1-72 (distribuidas en bloques)
    quiz_units: QUIZ_UNITS_A1,           # QUIZ UNITS distribuidos
    smart_zones: SMART_ZONE_A1,          # SMART ZONE distribuidos
    exam_prep: 1,                        # PREPARACIÓN EXAMEN FINAL (clase 97)
    final_exam: 1,                       # EXAMEN FINAL (clase 98)
    total_sequence: TOTAL_LESSONS_A1     # Secuencia completa 1-98
  }.freeze
  
  # Progresión del plan (ajustado con datos reales de screenshots)
  LEVEL_PROGRESSION = {
    'A1' => { 
      mandatory_lessons: INTRO_LESSONS_A1 + MAIN_LESSONS_A1 + EXAM_LESSONS_A1, # 82 obligatorias
      total_lessons: TOTAL_LESSONS_A1,
      optional_lessons: QUIZ_UNITS_A1 + SMART_ZONE_A1, # 16 opcionales
      next_level: 'A2',
      total_hours: 123 # 82 clases × 1.5 horas
    },
    'A2' => { 
      mandatory_lessons: 82, # Asumiendo estructura similar
      total_lessons: 98,
      optional_lessons: 16,
      next_level: 'B1',
      total_hours: 123
    },
    'B1' => { 
      mandatory_lessons: 82,
      total_lessons: 98,
      optional_lessons: 16,
      next_level: 'B2',
      total_hours: 123
    },
    'B2' => { 
      mandatory_lessons: 82,
      total_lessons: 98,
      optional_lessons: 16,
      next_level: 'C1',
      total_hours: 123
    },
    'C1' => { 
      mandatory_lessons: 82,
      total_lessons: 98,
      optional_lessons: 16,
      next_level: nil,
      total_hours: 123
    }
  }.freeze
  
  field :code, type: String
  field :title, type: String
  field :description, type: String
  field :level, type: String, default: 'A1'
  field :active, type: Mongoid::Boolean, default: true
  field :total_lessons, type: Integer, default: TOTAL_LESSONS_A1
  field :mandatory_lessons, type: Integer, default: 82 # INTRO + MAIN + EXAM
  field :total_hours, type: Integer, default: 123
  
  # Relationships
  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  
  # Mongoid doesn't support :through associations, use methods instead
  def users
    User.in(id: enrollments.pluck(:user_id))
  end
  
  # Validations
  validates :code, presence: true, uniqueness: true
  validates :title, presence: true
  validates :level, presence: true, inclusion: { in: AVAILABLE_LEVELS.values }
  validates :total_lessons, presence: true, numericality: { greater_than: 0 }
  validates :mandatory_lessons, presence: true, numericality: { greater_than: 0 }
  validates :total_hours, presence: true, numericality: { greater_than: 0 }
  
  # Validación personalizada para datos consistentes con el nivel
  validate :consistent_level_data
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_level, ->(level) { where(level: level) }
  scope :beginner_levels, -> { where(:level.in => [AVAILABLE_LEVELS[:a1], AVAILABLE_LEVELS[:a2]]) }
  scope :intermediate_levels, -> { where(:level.in => [AVAILABLE_LEVELS[:b1], AVAILABLE_LEVELS[:b2]]) }
  scope :advanced_levels, -> { where(:level.in => [AVAILABLE_LEVELS[:c1], AVAILABLE_LEVELS[:c2]]) }
  
  # Indexes
  index({ code: 1 }, { unique: true })
  index({ level: 1, active: 1 })
  index({ created_at: 1 })
  
  # Métodos de progresión de nivel
  def next_level
    LEVEL_PROGRESSION.dig(level, :next_level)
  end

  def has_next_level?
    next_level.present?
  end

  def level_info
    LEVEL_PROGRESSION[level] || {}
  end

  def expected_mandatory_lessons_for_level
    level_info[:mandatory_lessons] || MANDATORY_LESSONS_A1
  end

  def expected_total_lessons_for_level
    level_info[:total_lessons] || TOTAL_LESSONS_A1
  end

  def expected_hours_for_level
    level_info[:total_hours] || 123
  end

  # Métodos para determinar tipos de lecciones requeridas (basado en screenshots)
  def requires_intro_classes?
    # Todos los niveles empiezan con clases INTRO
    true
  end

  def intro_classes_count
    A1_STRUCTURE[:intro_classes] # 8 clases INTRO
  end

  def main_classes_count
    A1_STRUCTURE[:main_classes] # 72 clases principales
  end

  def quiz_units_count
    A1_STRUCTURE[:quiz_units] # 8 QUIZ UNITS distribuidos
  end

  def smart_zones_count
    A1_STRUCTURE[:smart_zones] # 8 SMART ZONE distribuidos
  end

  def requires_final_exam?
    # Todos los niveles requieren examen final
    true
  end

  def requires_exam_prep?
    # Todos los niveles requieren preparación para examen
    true
  end

  def allows_quiz_units?
    # Quiz Units disponibles como opcionales
    true
  end

  def allows_smart_zone?
    # Smart Zone disponible como opcional
    true
  end
  
  # Methods
  def create_lessons!
    return if lessons.count >= total_lessons
    
    (lessons.count + 1..total_lessons).each do |lesson_number|
      lessons.create!(lesson_number: lesson_number)
    end
  end

  # Verifica si un usuario puede avanzar al siguiente nivel
  def user_can_advance?(user)
    return false unless has_next_level?
    
    # Obtener lecciones obligatorias completadas
    completed_mandatory = user.lessons
                              .for_course(code)
                              .mandatory
                              .by_status(Lesson::COMPLETED)
                              .count
    
    # Verificar si completó las lecciones obligatorias mínimas
    required_lessons = expected_mandatory_lessons_for_level
    completed_mandatory >= required_lessons
  end

  # Calcula el progreso del usuario en este curso
  def user_progress(user)
    total_mandatory = expected_mandatory_lessons_for_level
    completed_mandatory = user.lessons
                              .for_course(code)
                              .mandatory
                              .by_status(Lesson::COMPLETED)
                              .count
    
    {
      completed_lessons: completed_mandatory,
      total_mandatory_lessons: total_mandatory,
      total_lessons: expected_total_lessons_for_level,
      progress_percentage: (completed_mandatory.to_f / total_mandatory * 100).round(2),
      can_advance: user_can_advance?(user),
      next_level: next_level
    }
  end

  private

  def consistent_level_data
    return unless level.present?
    
    expected = level_info
    return if expected.empty?
    
    errors.add(:total_lessons, "debe ser #{expected[:total_lessons]} para nivel #{level}") if total_lessons != expected[:total_lessons]
    errors.add(:mandatory_lessons, "debe ser #{expected[:mandatory_lessons]} para nivel #{level}") if mandatory_lessons != expected[:mandatory_lessons]
    errors.add(:total_hours, "debe ser #{expected[:total_hours]} para nivel #{level}") if total_hours != expected[:total_hours]
  end
end
