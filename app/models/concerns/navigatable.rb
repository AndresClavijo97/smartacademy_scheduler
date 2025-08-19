module Navigatable
  private

  def dashboard
    DashboardPage.new
  end

  def login_page(user)
    @login_page ||= LoginPage.new(user)
  end

  def schedule_page
    @schedule_page ||= SchedulePage.new
  end

  def schedule_modal
    @schedule_modal ||= ScheduleModalPage.new
  end

  def navigate_to_scheduler(user)
    login_page(user).login
    dashboard.go_to_schedule
    schedule_page.open_scheduler
  end
end
