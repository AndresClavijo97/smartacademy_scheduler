require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'

# Configuración de Capybara para plataforma externa
Capybara.configure do |config|
  config.run_server = false # No ejecutar servidor Rails
  config.app_host = ENV['PLATFORM_URL'] || 'https://tu-plataforma-externa.com'
  config.default_driver = :selenium_chrome_headless
  config.javascript_driver = :selenium_chrome_headless
  config.default_max_wait_time = 15
  config.default_normalize_ws = true
end

# Configuración de drivers
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end