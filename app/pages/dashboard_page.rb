class DashboardPage < ApplicationPage
  def go_to_schedule
    find('#IMAGE18').click
  end

  def wait_for_dashboard
    has_selector?('#vUSUNOMBRE') && has_text?('Bienvenido (a):')
  end

  def user_name
    find('#span_vUSUNOMBRE').text
  end

  def go_home
    find('#IMAGE3').click
  end
end