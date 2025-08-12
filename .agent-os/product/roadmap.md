# Product Roadmap

## Phase 0: Already Completed

The following features have been implemented:

- [x] Rails 8 Application Setup - Basic project structure with MongoDB integration `S`
- [x] UserPreference Model - Complete model with office, course, lesson, and schedule management `M`
- [x] Testing Framework Setup - RSpec and FactoryBot configuration `S`
- [x] Frontend Framework Setup - Tailwind CSS and Stimulus integration `S`

## Phase 1: Core MVP Functionality

**Goal:** Establish basic automated class registration system
**Success Criteria:** Successfully login and navigate to class schedule page

### Features

- [ ] User Authentication System - Secure credential storage and management `L`
- [ ] Login Page Object - Selenium automation for schoolpack.smart.edu.co login `M`
- [ ] Schedule Navigation - Navigate from login to schedule page `M`
- [ ] Basic Web Interface - Configuration page for user preferences `L`
- [ ] Value Objects Structure - Create domain objects for Course, Lesson, Schedule `M`

### Dependencies

- Selenium WebDriver gem installation
- Capybara configuration for browser automation

## Phase 2: Class Registration Automation

**Goal:** Automate the complete class booking process
**Success Criteria:** Successfully detect and register for available classes

### Features

- [ ] Class Modal Navigation - Open and interact with class selection modal `M`
- [ ] Available Class Detection - Find next available class in user's course `L`
- [ ] Class Registration Logic - Complete booking process with preferred time slots `L`
- [ ] Error Handling - Handle edge cases like required quizzes or unavailable slots `M`
- [ ] Background Job System - Daily 6am automated registration attempts `M`
- [ ] Notification System - Success/failure notifications for users `M`

### Dependencies

- Phase 1 completion
- Background job queue setup

## Phase 3: User Experience & Reliability

**Goal:** Polish user interface and improve system reliability
**Success Criteria:** 95% successful registration rate with intuitive UI

### Features

- [ ] Enhanced Web Interface - ViewComponent-based preference configuration `L`
- [ ] Dashboard - View registration history and upcoming classes `M`
- [ ] Retry Logic - Intelligent retry mechanisms for failed attempts `M`
- [ ] Logging System - Comprehensive logging for debugging and monitoring `S`
- [ ] User Feedback System - In-app status updates and confirmations `M`

### Dependencies

- Phase 2 completion
- Stable automation workflows

## Phase 4: Advanced Features

**Goal:** Add advanced scheduling and multi-user support
**Success Criteria:** Support multiple scheduling preferences and user accounts

### Features

- [ ] Multiple Schedule Preferences - Support for backup time preferences `L`
- [ ] Advanced Course Navigation - Support for all course levels (A1-C2) `L`
- [ ] Office Management - Handle multiple office locations intelligently `M`
- [ ] Performance Optimization - Faster page navigation and reduced resource usage `M`
- [ ] Mobile Responsive Interface - Optimize for mobile device configuration `L`

### Dependencies

- Phase 3 completion
- User feedback integration