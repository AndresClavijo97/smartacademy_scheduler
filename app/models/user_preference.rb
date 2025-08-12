class UserPreference
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :office, type: String
  field :course, type: String
  field :lesson, type: String
  field :schedule, type: Hash, default: {}
  field :credentials, type: Hash, default: {}
  field :user_id, type: String

  # Validations
  validates :office, presence: true, inclusion: { in: VALID_OFFICES }
  validates :course, presence: true, inclusion: { in: VALID_COURSES }
  validates :lesson, presence: true
  validates :user_id, presence: true, uniqueness: true

  # Indexes
  index({ office: 1, course: 1, lesson: 1 })
  index({ user_id: 1 }, { unique: true })

  # Constants
  VALID_OFFICES = %w[Bello Medellin Envigado].freeze
  VALID_COURSES = %w[A1 A2 B1 B2 C1 C2].freeze
  REQUIRED_CREDENTIAL_FIELDS = %w[username password].freeze

  # Scopes
  scope :by_office, ->(office) { where(office: office) }
  scope :by_course, ->(course) { where(course: course) }
  scope :active, -> { where(:schedule.ne => {}) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Class methods
  def self.find_or_create_for_user(user_id)
    find_or_create_by(user_id: user_id)
  end

  def self.find_by_user(user_id)
    by_user(user_id).first
  end

  # Instance methods
  def update_preferences(preferences_hash)
    preferences_hash.each do |key, value|
      send("#{key}=", value) if respond_to?("#{key}=")
    end
    save
  end

  def schedule_classes_for_day(day)
    schedule[day.to_s] || []
  end

  def add_schedule_for_day(day, time_slots)
    schedule[day.to_s] = time_slots
    save
  end

  def remove_schedule_for_day(day)
    schedule.delete(day.to_s)
    save
  end

  def has_schedule_for_day?(day)
    schedule[day.to_s].present?
  end

  def all_scheduled_days
    schedule.keys
  end

  def clear_all_schedules
    update(schedule: {})
  end

  def preferences_summary
    {
      office: office,
      course: course,
      lesson: lesson,
      scheduled_days: all_scheduled_days,
      total_scheduled_slots: schedule.values.flatten.count
    }
  end
end
