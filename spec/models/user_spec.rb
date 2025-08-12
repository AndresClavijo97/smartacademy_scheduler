require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'student registration' do
    context 'when a student wants to register for automated class booking' do
      it 'successfully creates an account with valid information' do
        user = build(:user)
        
        expect(user.save).to be true
        expect(user).to be_persisted
      end

      it 'rejects registration without required information' do
        user = build(:user, email: nil, first_name: nil)
        
        expect(user.save).to be false
        expect(user.errors).to be_present
      end

      it 'prevents duplicate email addresses' do
        unique_email = "student#{Time.current.to_i}@smart.edu.co"
        existing_user = create(:user, email: unique_email)
        duplicate_user = build(:user, email: unique_email)

        expect(duplicate_user.save).to be false
        expect(duplicate_user.errors[:email]).to include('has already been taken')
      end

      it 'requires valid email format' do
        user = build(:user, email: 'invalid-email')
        
        expect(user.save).to be false
        expect(user.errors[:email]).to include('is invalid')
      end

      it 'enforces minimum password length' do
        user = build(:user, password: '123', password_confirmation: '123')
        
        expect(user.save).to be false
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end
  end

  describe 'authentication' do
    context 'when a student wants to login' do
      let(:student) { create(:user) }

      it 'authenticates with correct credentials' do
        authenticated_user = User.find_for_authentication(email: student.email)
        
        expect(authenticated_user).to eq(student)
        expect(authenticated_user.valid_password?('password123')).to be true
      end

      it 'rejects incorrect password' do
        authenticated_user = User.find_for_authentication(email: student.email)
        
        expect(authenticated_user.valid_password?('wrongpassword')).to be false
      end

      it 'cannot find non-existent user' do
        authenticated_user = User.find_for_authentication(email: 'nonexistent@example.com')
        
        expect(authenticated_user).to be_nil
      end
    end
  end

  describe 'schoolpack integration' do
    context 'when storing credentials for automation' do
      let(:automation_user) { create(:user, :automation_ready) }

      it 'stores schoolpack credentials' do
        expect(automation_user.schoolpack_username).to be_present
        expect(automation_user.schoolpack_password).to be_present
      end

      it 'requires schoolpack username' do
        user = build(:user, schoolpack_username: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_username]).to include("can't be blank")
      end

      it 'requires schoolpack password' do
        user = build(:user, schoolpack_password: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_password]).to include("can't be blank")
      end
    end
  end

  describe 'user preferences integration' do
    context 'when connecting with class scheduling' do
      let(:student_with_preferences) { create(:user, :with_preference) }

      it 'can be associated with scheduling preferences' do
        expect(student_with_preferences.user_preference).to be_present
      end

      it 'automatically destroys preferences when user is deleted' do
        preference_id = student_with_preferences.user_preference.id
        student_with_preferences.destroy

        expect(UserPreference.where(id: preference_id)).to be_empty
      end
    end

    context 'when creating specific student types' do
      it 'creates Bello office students with A1 course' do
        bello_student = create(:user, :bello_student)
        
        expect(bello_student.user_preference.office).to eq('Bello')
        expect(bello_student.user_preference.course).to eq('A1')
      end

      it 'creates Medellin office students with B1 course' do
        medellin_student = create(:user, :medellin_student)
        
        expect(medellin_student.user_preference.office).to eq('Medellin')
        expect(medellin_student.user_preference.course).to eq('B1')
      end

      it 'creates students with full weekly schedules' do
        busy_student = create(:user, :with_full_schedule)
        
        expect(busy_student.user_preference.schedule.keys.size).to be >= 3
        expect(busy_student.user_preference.schedule['monday']).to be_present
      end
    end
  end

  describe 'account management' do
    context 'when updating profile information' do
      let(:student) { create(:user) }

      it 'updates profile details' do
        student.update!(first_name: 'Updated', last_name: 'Name')
        
        expect(student.first_name).to eq('Updated')
        expect(student.last_name).to eq('Name')
      end

      it 'updates schoolpack credentials' do
        new_username = 'new.username'
        new_password = 'new_schoolpack_password'
        
        student.update!(
          schoolpack_username: new_username,
          schoolpack_password: new_password
        )
        
        expect(student.schoolpack_username).to eq(new_username)
        expect(student.schoolpack_password).to eq(new_password)
      end

      it 'is active by default' do
        expect(student.active).to be true
      end

      it 'can be deactivated' do
        inactive_student = create(:user, :inactive)
        
        expect(inactive_student.active).to be false
      end
    end
  end

  describe 'enhanced validations and relationships' do
    context 'when validating required fields' do
      it 'requires first_name presence' do
        user = build(:user, first_name: nil)
        
        expect(user.save).to be false
        expect(user.errors[:first_name]).to include("can't be blank")
      end

      it 'requires last_name presence' do
        user = build(:user, last_name: nil)
        
        expect(user.save).to be false
        expect(user.errors[:last_name]).to include("can't be blank")
      end

      it 'requires schoolpack_username presence' do
        user = build(:user, schoolpack_username: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_username]).to include("can't be blank")
      end

      it 'requires schoolpack_password presence' do
        user = build(:user, schoolpack_password: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_password]).to include("can't be blank")
      end
    end

    context 'when managing schoolpack credentials' do
      it 'stores schoolpack username and password as strings' do
        user = build(:user)
        username = 'student.username'
        password = 'schoolpack_secret123'
        
        user.schoolpack_username = username
        user.schoolpack_password = password
        user.save
        
        expect(user.schoolpack_username).to eq(username)
        expect(user.schoolpack_password).to eq(password)
      end

      it 'validates schoolpack credentials presence' do
        user = build(:user, schoolpack_username: '', schoolpack_password: '')
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_username]).to include("can't be blank")
        expect(user.errors[:schoolpack_password]).to include("can't be blank")
      end
    end

    context 'when managing user preferences relationship' do
      it 'has one user_preference with dependent destroy' do
        user = create(:user)
        preference = create(:user_preference, user: user)
        
        expect(user.user_preference).to eq(preference)
        
        user.destroy
        expect(UserPreference.where(id: preference.id).exists?).to be false
      end

      it 'allows user creation without immediate preference' do
        user = create(:user)
        
        expect(user).to be_persisted
        expect(user.user_preference).to be_nil
      end

      it 'creates preference through association' do
        user = create(:user)
        
        user.create_user_preference(
          office: 'Bello',
          course: 'A1',
          lesson: 'Basic English',
          user_id: user.id.to_s
        )
        
        expect(user.user_preference).to be_present
        expect(user.user_preference.office).to eq('Bello')
      end
    end

    context 'when managing user account status' do
      it 'defaults to active status' do
        user = create(:user)
        
        expect(user.active).to be true
      end

      it 'can be deactivated' do
        user = create(:user, active: false)
        
        expect(user.active).to be false
      end

      it 'includes active scope functionality' do
        active_user = create(:user, active: true)
        inactive_user = create(:user, active: false)
        
        expect(User.where(active: true)).to include(active_user)
        expect(User.where(active: true)).not_to include(inactive_user)
      end
    end

    context 'when indexing for performance' do
      it 'has proper indexes defined' do
        index_keys = User.index_specifications.map(&:key)
        expect(index_keys).to include({ created_at: 1 })
        expect(index_keys).to include({ active: 1 })
      end
    end
  end

  describe 'devise configuration' do
    context 'when checking authentication modules' do
      it 'includes required Devise modules' do
        expected_modules = [:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable]
        
        expect(User.devise_modules).to include(*expected_modules)
      end
    end

    context 'when verifying document structure' do
      it 'includes Mongoid document functionality' do
        expect(User.included_modules).to include(Mongoid::Document)
        expect(User.included_modules).to include(Mongoid::Timestamps)
      end
    end
  end
end
