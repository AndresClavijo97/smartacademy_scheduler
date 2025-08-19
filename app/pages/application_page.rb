class ApplicationPage
  include Capybara::DSL

  private

  def find_and_click(selector)
    find(selector).click
  end

  def within(selector, &block)
    Capybara.current_session.within(selector, &block)
  end

  def logout
    accept_confirm do
      find("#SALIR").click
    end
  end

  def execute(...)
    evaluate_script(...)
  end
end
