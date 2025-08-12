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
        create(:user, email: 'student@smart.edu.co')
        duplicate_user = build(:user, email: 'student@smart.edu.co')

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

      it 'securely stores schoolpack credentials' do
        expect(automation_user.schoolpack_username).to be_present
        expect(automation_user.schoolpack_password_encrypted).to be_present
      end

      it 'requires schoolpack username' do
        user = build(:user, schoolpack_username: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_username]).to include("can't be blank")
      end

      it 'requires encrypted schoolpack password' do
        user = build(:user, schoolpack_password_encrypted: nil)
        
        expect(user.save).to be false
        expect(user.errors[:schoolpack_password_encrypted]).to include("can't be blank")
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
        new_encrypted_password = Faker::Crypto.sha256
        
        student.update!(
          schoolpack_username: new_username,
          schoolpack_password_encrypted: new_encrypted_password
        )
        
        expect(student.schoolpack_username).to eq(new_username)
        expect(student.schoolpack_password_encrypted).to eq(new_encrypted_password)
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
