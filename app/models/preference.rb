class Preference
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  # Constants
  OFFICES = %w[Bello Medellin Envigado].freeze
  COURSES = %w[A1 A2 B1 B2 C1 C2].freeze

  # Fields
  field :office, type: String
  field :course, type: String
  field :schedule, type: Hash, default: {}

  # Relationships
  embedded_in :user

  # Validations
  validates :office, presence: true, inclusion: { in: OFFICES }
  validates :course, presence: true, inclusion: { in: COURSES }

  # Scopes
  scope :by_office, ->(office) { where(office: office) }
  scope :by_course, ->(course) { where(course: course) }
  scope :active, -> { where(:schedule.ne => {}) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Indexes
  index({ office: 1, course: 1, lesson: 1 })
  index({ user_id: 1 }, { unique: true })
end
