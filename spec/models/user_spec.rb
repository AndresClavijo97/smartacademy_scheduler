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

  describe 'lesson association' do
    context 'when creating lessons for users' do
      let(:student) { create(:user) }

      it 'can have lessons associated' do
        lesson = create(:lesson, user: student)

        expect(student.lessons).to include(lesson)
        expect(lesson.user).to eq(student)
      end

      it 'destroys associated lessons when user is deleted' do
        lesson = create(:lesson, user: student)
        lesson_id = lesson.id
        student.destroy

        expect(Lesson.where(id: lesson_id).exists?).to be false
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

    context 'when managing lesson relationships' do
      it 'can have multiple lessons' do
        user = create(:user)
        lesson1 = create(:lesson, user: user, number: 1)
        lesson2 = create(:lesson, user: user, number: 2)

        expect(user.lessons.count).to eq(2)
        expect(user.lessons).to include(lesson1, lesson2)
      end

      it 'allows user creation without immediate lessons' do
        user = create(:user)

        expect(user).to be_persisted
        expect(user.lessons).to be_empty
      end

      it 'can create lessons through association' do
        user = create(:user)

        lesson = user.lessons.create!(
          level: 'A1',
          number: 1,
          description: 'First lesson',
          kind: 'intro',
          office: 'Bello',
          scheduled_at: Date.current,
          start_time: DateTime.current.change(hour: 8),
          end_time: DateTime.current.change(hour: 9, min: 30),
          status: 'pending'
        )

        expect(user.lessons).to include(lesson)
        expect(lesson.user).to eq(user)
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
        expected_modules = [ :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable ]

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
