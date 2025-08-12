# API Specification

This is the API specification for the spec detailed in @.agent-os/specs/2025-08-12-user-authentication-system/spec.md

## Endpoints

### POST /users/sign_up

**Purpose:** User registration using Devise registrations controller
**Parameters:** 
- user[email] (required, string, valid email format)
- user[password] (required, string, minimum 8 characters)
- user[password_confirmation] (required, string, must match password)
- user[first_name] (required, string)
- user[last_name] (required, string)
- user[schoolpack_username] (required, string)
- user[schoolpack_password] (required, string)
**Response:** 
- Success (302): User created, redirect to after_sign_up_path
- Error (200): Registration form with validation errors
**Errors:** Email taken, password too weak, schoolpack credential validation failed

### POST /users/sign_in

**Purpose:** User authentication using Devise sessions controller
**Parameters:**
- user[email] (required, string)
- user[password] (required, string) 
- user[remember_me] (optional, boolean)
**Response:**
- Success (302): Authentication successful, redirect to after_sign_in_path
- Error (200): Login form with error message
**Errors:** Invalid email/password combination, account locked

### DELETE /users/sign_out

**Purpose:** User session termination using Devise sessions controller
**Parameters:** None (uses current session)
**Response:**
- Success (302): Session terminated, redirect to after_sign_out_path
**Errors:** None (always succeeds)

### GET /users/edit

**Purpose:** Display user profile edit form using Devise registrations controller
**Parameters:** None (authenticated user)
**Response:**
- Success (200): User edit profile page
- Error (302): Redirect to sign in if not authenticated
**Errors:** Session expired, user not found

### PUT /users

**Purpose:** Update user profile using Devise registrations controller
**Parameters:**
- user[email] (optional, string, valid email format)
- user[password] (optional, string, minimum 8 characters)
- user[password_confirmation] (optional, string, required if password provided)
- user[current_password] (required, string)
- user[first_name] (optional, string)
- user[last_name] (optional, string)
- user[schoolpack_username] (optional, string)
- user[schoolpack_password] (optional, string)
**Response:**
- Success (302): Profile updated, redirect to after_update_path
- Error (200): Edit form with validation errors
**Errors:** Email already taken, incorrect current password, password confirmation mismatch

## Controllers

### Users::RegistrationsController (extends Devise::RegistrationsController)
- **new (GET):** Display registration form with custom fields
- **create (POST):** Process registration, encrypt schoolpack credentials, create UserPreference
- **edit (GET):** Display profile edit form with schoolpack credentials
- **update (PUT):** Update profile and schoolpack credentials
- **Business Logic:** Custom strong parameters, schoolpack credential encryption, UserPreference creation
- **Error Handling:** Custom validation messages, secure error logging

### Users::SessionsController (extends Devise::SessionsController)  
- **new (GET):** Display custom login form with Tailwind styling
- **create (POST):** Authenticate user with custom success/failure handling
- **destroy (DELETE):** Terminate session with custom redirect logic
- **Business Logic:** Custom after_sign_in_path logic, session management
- **Error Handling:** Custom error messages, failed login attempt logging

## Devise Configuration

### Routes (config/routes.rb)
```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }
  
  # Custom authenticated root
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end
  
  # Unauthenticated root
  root 'users/sessions#new'
end
```

### Devise Settings (config/initializers/devise.rb)
- **Mongoid Integration:** Configure Devise to work with Mongoid
- **Security Settings:** Strong password requirements, session timeout
- **Custom Fields:** Allow additional registration parameters
- **Redirects:** Custom after_sign_in_path and after_sign_up_path logic

## External Dependencies Required

- **devise** - Complete authentication solution for Rails
- **devise-mongoid** - Mongoid integration for Devise
- **warden** - Authentication wrapper (comes with Devise)

## Custom Enhancements

### SchoolpackCredentialValidator
- Custom validator to verify schoolpack.smart.edu.co credentials during registration
- Integration with automation system for credential verification

### UserPreferenceIntegration
- Automatic UserPreference creation/linking during user registration
- Seamless data flow between authentication and scheduling preferences