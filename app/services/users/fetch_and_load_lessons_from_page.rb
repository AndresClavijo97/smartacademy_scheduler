class Users::FetchAndLoadLessonsFromPage
  include Navigatable

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
    navigate_to_scheduler(@user)

    @data = schedule_modal.fetch_all_lessions
  end

  def bulk_insert_lessons
    @user.lessons.destroy_all
    @user.lessons.create!(@data)
  end
end
