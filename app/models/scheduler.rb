class Scheduler
  # TODO: check if convert this module into class
  include Navigatable

  private attr_reader :user

  def initialize(user)
    @user = user
  end

  def schedule(lessions)
    navigate_to_scheduler(user)

    lessions.each { schedule_modal.schedule(it) }
    schedule_modal.schedule(lessions.first)
  end
end
