# Technical Stack

## Backend Framework
- **Application Framework:** Rails 8.0.2
- **Language:** Ruby 3.4.5 (+PRISM)
- **Database System:** MongoDB with Mongoid ODM 8.1
- **Background Jobs:** ActiveJob (built-in Rails)
- **Web Server:** Puma 6.6.0

## Frontend Framework
- **JavaScript Framework:** Stimulus (Hotwire)
- **Import Strategy:** importmaps
- **CSS Framework:** Tailwind CSS
- **UI Component Library:** ViewComponent + ERB
- **Page Accelerator:** Turbo Rails (Hotwire)

## Architecture Patterns
- **Design Pattern:** Layered Design Architecture
- **Value Objects:** /app/value_objects for domain objects
- **Page Objects:** /app/pages for Selenium WebDriver navigation
- **Namespaces:** Grouped related objects with declarative naming
- **OOP Principles:** Avoid Law of Demeter with descriptive wrappers

## Testing & Quality
- **Testing Framework:** RSpec 7.0
- **Test Data:** FactoryBot Rails
- **Code Style:** Rubocop Rails Omakase
- **Security Analysis:** Brakeman
- **BDD Approach:** Behavior-driven development with RSpec

## Web Automation
- **Browser Automation:** Selenium WebDriver
- **Testing Framework:** Capybara (for browser interaction DSL)
- **Target Platform:** schoolpack.smart.edu.co

## Development Tools
- **Asset Pipeline:** Propshaft
- **Hot Reloading:** Rails live reload
- **Debugging:** Debug gem
- **Deployment:** Docker ready (Dockerfile included)

## Hosting & Infrastructure
- **Application Hosting:** TBD
- **Database Hosting:** MongoDB (local/cloud TBD)
- **Asset Hosting:** Rails asset pipeline
- **Deployment Solution:** Kamal (included in Gemfile)
- **Code Repository:** Local Git repository

## Additional Tools
- **Fonts Provider:** System fonts / TBD
- **Icon Library:** TBD
- **Caching:** Bootsnap for boot time optimization
- **Performance:** Thruster for HTTP optimization