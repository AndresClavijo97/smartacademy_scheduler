# SmartAcademy Automation System - Technical Specification

## Overview
Automated class reservation system that integrates with SmartAcademia platform to manage A1 English course scheduling and enrollment.

## System Architecture

### Core Components
1. **User Management** - Student authentication and profile management
2. **Course Management** - A1 course structure with 60 lessons
3. **Page Automation Layer** - Capybara-based web automation for SmartAcademia
4. **Reservation Queue** - Automated class booking system
5. **Schedule Management** - Time slot management (6AM-7:30PM, 90min sessions)

## Technical Stack
- **Backend**: Ruby on Rails 8.0.2
- **Database**: MongoDB with Mongoid ODM
- **Authentication**: Devise with custom fields
- **Web Automation**: Capybara + Selenium WebDriver (Chrome)
- **Frontend**: Tailwind CSS (minimal UI for configuration)

## Data Models

### User
```ruby
class User
  # Devise fields
  field :email, type: String
  field :encrypted_password, type: String
  
  # Custom profile fields
  field :first_name, type: String
  field :last_name, type: String
  field :active, type: Boolean, default: true
  
  # SmartAcademia credentials
  field :schoolpack_username, type: String
  field :schoolpack_password, type: String
  
  # Relationships
  has_one :user_preference, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
end
```

### Course
```ruby
class Course
  # Constants
  LESSON_DURATION_MINUTES = 90
  TOTAL_LESSONS_A1 = 60
  AVAILABLE_LEVELS = %w[A1 A2 B1 B2 C1 C2].freeze
  
  # Fields
  field :title, type: String
  field :description, type: String
  field :level, type: String, default: 'A1'
  field :active, type: Boolean, default: true
  field :total_lessons, type: Integer, default: TOTAL_LESSONS_A1
  
  # Relationships
  has_many :lessons, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
end
```

### Lesson
```ruby
class Lesson
  # Constants
  DURATION_MINUTES = 90
  MAX_CLASSES_PER_DAY = 10
  
  # Fields
  field :lesson_number, type: Integer
  field :scheduled_date, type: Date
  field :start_time, type: Time
  field :end_time, type: Time
  field :completed, type: Boolean, default: false
  
  # Relationships
  belongs_to :course
end
```

### Enrollment
```ruby
class Enrollment
  # Fields
  field :enrolled_at, type: DateTime, default: -> { Time.current }
  field :completed_at, type: DateTime
  field :progress, type: Integer, default: 0
  
  # Relationships
  belongs_to :user
  belongs_to :course
end
```

## Page Automation Layer

### ApplicationPage
```ruby
class ApplicationPage
  include Capybara::DSL
  
  def initialize(user)
    @user = user
  end
  
  private
  
  attr_reader :user
end
```

### LoginPage
```ruby
class LoginPage < ApplicationPage
  def login
    visit('https://schoolpack.smart.edu.co/idiomas/alumnos.aspx')
    fill_in('vUSUCOD', with: user.schoolpack_username)
    fill_in('vPASS', with: user.schoolpack_password)
    click_button('BUTTON1')
  end
end
```

## Business Rules

### Scheduling Constraints
- **Operating Hours**: 6:00 AM - 7:30 PM daily
- **Lesson Duration**: 90 minutes per session
- **Daily Capacity**: Maximum 10 classes per day
- **Course Structure**: A1 level = exactly 60 lessons
- **Time Slots**: 
  - 06:00-07:30, 07:30-09:00, 09:00-10:30, 10:30-12:00
  - 12:00-13:30, 13:30-15:00, 15:00-16:30, 16:30-18:00
  - 18:00-19:30

### User Management
- **Authentication**: Email + schoolpack credentials required
- **Profile**: First name, last name, schoolpack username/password
- **Enrollment**: One active course per user
- **Progress Tracking**: Percentage completion based on attended lessons

## Feature Specifications

### Phase 1: Core Infrastructure ✅
- [x] User authentication with Devise
- [x] MongoDB models (User, Course, Lesson, Enrollment)
- [x] Capybara automation layer
- [x] Successful SmartAcademia login integration

### Phase 2: Navigation & Discovery
- [ ] Dashboard page exploration
- [ ] Menu structure mapping
- [ ] Available actions identification
- [ ] Class reservation flow discovery

### Phase 3: Reservation System
- [ ] Reservation page automation
- [ ] Time slot selection logic
- [ ] Booking confirmation handling
- [ ] Error handling and retries

### Phase 4: Queue Management
- [ ] Reservation queue model
- [ ] Background job processing
- [ ] Queue status tracking
- [ ] Automatic retry mechanisms

### Phase 5: Monitoring & Reporting
- [ ] Reservation success/failure tracking
- [ ] User notification system
- [ ] Admin dashboard (optional)
- [ ] Performance monitoring

## Technical Implementation Tasks

### Immediate Next Steps
1. **Dashboard Page Creation**
   ```ruby
   class DashboardPage < ApplicationPage
     def navigate_to_reservations
       # Implement navigation logic
     end
     
     def get_available_menu_options
       # Extract navigation elements
     end
   end
   ```

2. **Platform Exploration Service**
   ```ruby
   class PlatformExplorationService
     def initialize(user)
       @user = user
       @login_page = LoginPage.new(user)
       @dashboard_page = DashboardPage.new(user)
     end
     
     def explore_interface
       @login_page.login
       @dashboard_page.get_available_menu_options
     end
   end
   ```

3. **Reservation Queue Model**
   ```ruby
   class ReservationQueue
     include Mongoid::Document
     
     field :user_id, type: BSON::ObjectId
     field :lesson_id, type: BSON::ObjectId
     field :preferred_date, type: Date
     field :preferred_time, type: Time
     field :status, type: String # pending, processing, completed, failed
     field :attempts, type: Integer, default: 0
     field :last_attempt_at, type: DateTime
     field :error_message, type: String
     
     belongs_to :user
     belongs_to :lesson
   end
   ```

### API Integration Points
- **SmartAcademia Platform**: `https://schoolpack.smart.edu.co/idiomas/alumnos.aspx`
- **Authentication Endpoint**: Form-based login with vUSUCOD/vPASS
- **Navigation**: TBD based on platform exploration

### Configuration
```ruby
# config/initializers/capybara.rb
Capybara.configure do |config|
  config.run_server = false
  config.app_host = ENV['PLATFORM_URL'] || 'https://schoolpack.smart.edu.co'
  config.default_driver = :selenium_chrome_headless
  config.default_max_wait_time = 15
end
```

## Success Criteria
1. ✅ User can authenticate with SmartAcademia credentials
2. 🔄 System can navigate SmartAcademia interface programmatically
3. ⏳ Automated class reservation without manual intervention
4. ⏳ Queue system handles multiple reservation requests
5. ⏳ Error handling and retry mechanisms work reliably
6. ⏳ User receives confirmation of successful reservations

## Risk Mitigation
- **Rate Limiting**: Implement delays between requests
- **Session Management**: Handle session timeouts gracefully
- **Error Recovery**: Retry failed operations with exponential backoff
- **UI Changes**: Design flexible selectors that adapt to minor interface changes
- **Authentication**: Secure credential storage and handling

## Performance Requirements
- **Response Time**: < 30 seconds per reservation attempt
- **Availability**: 99% uptime during operating hours (6AM-7:30PM)
- **Concurrency**: Support up to 50 simultaneous users
- **Data Integrity**: No duplicate reservations, accurate progress tracking