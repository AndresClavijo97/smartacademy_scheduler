class ApplicationPage
  include Capybara::DSL
  
  def initialize(user)
    @user = user
  end
  
  private
  
  attr_reader :user
end