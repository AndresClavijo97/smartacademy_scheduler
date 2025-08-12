# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-08-12-user-authentication-system/spec.md

## Changes

### New Collections

**Users Collection**
- Primary collection for user authentication and profile management
- Stores encrypted passwords and schoolpack credentials
- Links to existing UserPreference collection

### UserPreference Collection Modification
- Add user_id field to link with Users collection
- Update existing records to support new authentication system

## Schema Specifications

### Users Model (Mongoid Document with Devise)

```ruby
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Devise fields (automatically added)
  # field :email,                 type: String, default: ""
  # field :encrypted_password,    type: String, default: ""
  # field :reset_password_token,  type: String
  # field :reset_password_sent_at,type: Time
  # field :remember_created_at,   type: Time
  
  # Custom profile fields
  field :first_name, type: String
  field :last_name, type: String
  field :active, type: Boolean, default: true
  
  # Schoolpack credentials (encrypted)
  field :schoolpack_username, type: String
  field :schoolpack_password_encrypted, type: String
  
  # Relationships
  has_one :user_preference, dependent: :destroy
  
  # Validations (additional to Devise)
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :schoolpack_username, presence: true
  validates :schoolpack_password_encrypted, presence: true
  
  # Devise indexes (automatically created)
  # index({ email: 1 }, { unique: true })
  # index({ reset_password_token: 1 }, { unique: true, sparse: true })
  
  # Custom indexes
  index({ created_at: 1 })
  index({ active: 1 })
end
```

### UserPreference Model Update

```ruby
# Add to existing UserPreference model
belongs_to :user, optional: true  # Optional for backward compatibility

# New index
index({ user_id: 1 }, { sparse: true })
```

## Migration Strategy

### Phase 1: Add User Model
1. Create User model with all fields and validations
2. Set up authentication system without breaking existing functionality

### Phase 2: Link UserPreference
1. Add user_id field to UserPreference model
2. Create migration script to handle existing UserPreference records
3. Update UserPreference to work with or without user_id (backward compatibility)

### Phase 3: Data Migration
1. Create users for existing UserPreference records where possible
2. Update UserPreference records to link with created users
3. Add validation to require user_id for new UserPreference records

## Rationale

**Separate User Model**: Follows single responsibility principle - User handles authentication, UserPreference handles class scheduling preferences

**Backward Compatibility**: Gradual migration allows existing UserPreference records to continue functioning during transition

**Encrypted Credentials**: Schoolpack credentials stored separately from user password for security isolation

**Indexes**: Optimized for common queries (email lookup, user preference retrieval, session token validation)