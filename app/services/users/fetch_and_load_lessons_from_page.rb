class Users::FetchAndLoadLessonsFromPage
  def initialize(user)
    @user = user
  end

  def call
    fetch_lessons_from_page
    bulk_insert_lessons
  end

  private

  attr_reader :user, :lessons_data

  def fetch_lessons_from_page
    login_page.login
    dashboard.go_to_schedule
    schedule.open_scheduler
    @data = schedule_modal.fetch_all_lessions
  end

  def dashboard
    DashboardPage.new
  end

  def login_page
    LoginPage.new(@user)
  end

  def schedule
    SchedulePage.new
  end

  def schedule_modal
    ScheduleModalPage.new
  end

  def bulk_insert_lessons
    @user.lessons.destroy_all
    @user.lessons.create!(@data)
  end
end