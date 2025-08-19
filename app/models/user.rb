class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  # field :sign_in_count,      type: Integer, default: 0
  # field :current_sign_in_at, type: Time
  # field :last_sign_in_at,    type: Time
  # field :current_sign_in_ip, type: String
  # field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  ## Custom profile fields
  field :first_name, type: String
  field :last_name, type: String
  field :active, type: Boolean, default: true

  ## Schoolpack credentials
  field :schoolpack_username, type: String
  field :schoolpack_password, type: String

  ## Relationships
  has_many :lessons, class_name: "Lesson", inverse_of: :user, dependent: :destroy

  embeds_one :preferences, class_name: Preference

  accepts_nested_attributes_for :preferences

  ## Validations (additional to Devise)
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :schoolpack_username, presence: true
  validates :schoolpack_password, presence: true

  ## Custom indexes
  index({ created_at: 1 })
  index({ active: 1 })

  # Simple method to register a class
  def register_class(course_code, date, time)
    return { success: false, error: "Usuario inactivo" } unless active?

    lesson = Lesson.create!(
      user: self,
      course_code: course_code,
      scheduled_date: date,
      start_time: time,
      end_time: calculate_end_time(time),
      duration_minutes: 90,
      status: "scheduled"
    )

    {
      success: true,
      lesson_id: lesson.id.to_s,
      message: "Clase #{course_code} registrada para #{date} a las #{time}"
    }
  rescue => e
    { success: false, error: e.message }
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end


  private

  def calculate_end_time(start_time)
    time = Time.parse(start_time)
    (time + 90.minutes).strftime("%H:%M")
  end
end
