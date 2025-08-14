class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    # Dashboard for authenticated users
  end
end