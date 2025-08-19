require "capybara"
require "capybara/dsl"
require "selenium-webdriver"

# Configuración de Capybara para plataforma externa
Capybara.configure do |config|
  config.run_server = false # No ejecutar servidor Rails
  config.app_host = ENV["PLATFORM_URL"] || "https://tu-plataforma-externa.com"
  config.default_driver = :selenium_chrome
  config.javascript_driver = :selenium_chrome
  config.default_max_wait_time = 15
  config.default_normalize_ws = true
end

# Configuración de drivers
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  # Anti-detección
  options.add_argument("--disable-blink-features=AutomationControlled")

  options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")

  # Otros argumentos
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-gpu")

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
