# Product Mission

## Pitch

SmartAcademy is an English class registration automator that helps students secure spots in limited classes by providing automatic registration at 6am when schedules become available.

## Users

### Primary Customers

- **English Students**: People enrolled in schoolpack.smart.edu.co who struggle to secure limited class spots
- **Busy Users**: Students who cannot wake up at 6am to register for classes manually

### User Personas

**English Student** (18-35 years old)
- **Role:** Active student in A1-C2 courses
- **Context:** Studies English at smart.edu.co with limited schedules that fill up quickly
- **Pain Points:** Missing classes due to inability to secure spots, having to wake up at 6am, manually competing for spaces
- **Goals:** Secure classes consistently, automate the registration process, maintain academic progress

## The Problem

### Limited Class Availability

Students miss English classes because limited spots fill up quickly when they open at 6am daily. This results in academic delays and frustration.

**Our Solution:** Automation of the registration process using Selenium WebDriver to register for classes as soon as they become available.

### Inefficient Manual Process

Students must wake up early and manually compete for available spaces, creating unnecessary stress.

**Our Solution:** Preference configuration system that handles registration automatically according to desired schedules.

## Differentiators

### Complete Automation

Unlike manual registration, we provide complete automation of the booking process. This results in higher registration success without manual intervention.

### Intelligent Schedule Configuration

Unlike generic solutions, we are specifically designed for schoolpack.smart.edu.co with specific office, course, and lesson configuration.

## Key Features

### Core Features

- **Preference Configuration:** Allows users to configure office, course, lesson, and desired schedules
- **Automatic Registration:** Automates the login and class registration process using Selenium WebDriver
- **Task Scheduling:** Executes registration attempts daily at 6am using background jobs
- **Credential Management:** Securely stores and uses user credentials

### Automation Features

- **Intelligent Web Navigation:** Automatically navigates through login, schedule, class modal, and registration
- **Available Class Detection:** Automatically finds the next available class in the user's course
- **Edge Case Handling:** Manages cases like required quizzes or unavailable classes
- **Notification System:** Informs users about registration status (success or errors)