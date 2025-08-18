class Preference
  include Mongoid::Document
  include Mongoid::Timestamps

  # Constants
  VALID_OFFICES = %w[Bello Medellin Envigado].freeze
  VALID_COURSES = %w[A1 A2 B1 B2 C1 C2].freeze

  # Fields
  field :office, type: String
  field :course, type: String
  field :lesson, type: String
  field :schedule, type: Hash, default: {}
  field :user_id, type: String

  # Relationships
  embedded_in :user, optional: true # Optional for backward compatibility

  # Validations
  validates :office, presence: true, inclusion: { in: VALID_OFFICES }
  validates :course, presence: true, inclusion: { in: VALID_COURSES }
  validates :lesson, presence: true
  validates :user_id, presence: true, uniqueness: true

  # Scopes
  scope :by_office, ->(office) { where(office: office) }
  scope :by_course, ->(course) { where(course: course) }
  scope :active, -> { where(:schedule.ne => {}) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Indexes
  index({ office: 1, course: 1, lesson: 1 })
  index({ user_id: 1 }, { unique: true })
end
