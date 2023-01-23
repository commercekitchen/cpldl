# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:user) { FactoryBot.create(:user) }
  let(:course1) { FactoryBot.create(:course_with_lessons) }
  let(:course2) { FactoryBot.create(:course_with_lessons) }
  let(:course3) { FactoryBot.create(:course) }

  context '#tracking_course?' do
    let!(:course_progress1) { FactoryBot.create(:course_progress, user: user, course: course1, tracked: true) }
    let!(:course_progress2) { FactoryBot.create(:course_progress, user: user, course: course2, tracked: false) }

    it 'should return true for a tracked course' do
      expect(user.tracking_course?(course1.id)).to be true
    end

    it 'should return false for an un-tracked course' do
      expect(user.tracking_course?(course2.id)).to be false
    end

  end

  context '#completed_lesson_ids' do
    let(:course_progress1) { FactoryBot.create(:course_progress, course: course1, user: user) }
    let(:course_progress2) { FactoryBot.create(:course_progress, course: course2, user: user) }
    let(:course_progress3) { FactoryBot.create(:course_progress, course: course3, user: user) }

    before(:each) do
      course1.lessons.each do |l|
        FactoryBot.create(:lesson_completion, course_progress: course_progress1, lesson: l)
      end

      course2.lessons.each do |l|
        FactoryBot.create(:lesson_completion, course_progress: course_progress2, lesson: l)
      end
    end

    it 'should return an array of all completed lesson ids for the course' do
      expect(user.completed_lesson_ids(course1.id)).to contain_exactly(*course1.lessons.map(&:id))
      expect(user.completed_lesson_ids(course2.id)).to contain_exactly(*course2.lessons.map(&:id))
    end

    it 'should return an empty array if the user has not completed any lessons' do
      expect(user.completed_lesson_ids(course3.id)).to eq([])
    end

    it 'should return an empty array if the user has not started the course' do
      expect(user.completed_lesson_ids(123)).to eq([])
    end
  end

  context '#completed_course_ids' do
    let(:course_progress1) { FactoryBot.create(:course_progress, course: course1, tracked: true, completed_at: Time.zone.now) }
    let(:course_progress2) { FactoryBot.create(:course_progress, course: course2, tracked: true) }
    let(:course_progress3) { FactoryBot.create(:course_progress, course: course3, tracked: true, completed_at: Time.zone.now) }

    it 'should return an array of all completed course ids' do
      user.course_progresses << [course_progress1, course_progress2, course_progress3]
      expect(user.completed_course_ids).to contain_exactly(course1.id, course3.id)
    end

    it 'should return an empty array if the user has not completed any lessons' do
      expect(user.completed_course_ids).to eq([])
    end
  end

  context 'user information' do
    it 'returns current_roles' do
      user.add_role(:admin)
      expect(user.current_roles).to include('admin')
    end

    it 'returns preferred language' do
      user.profile = FactoryBot.create(:profile, user: user, language: @english)
      expect(user.preferred_language).to eq('English')
    end
  end

  context 'delegated methods' do
    context 'missing profile' do
      let(:user) { FactoryBot.create(:user, profile: nil) }

      it 'library_location_name should be nil' do
        expect(user.library_location_name).to be_nil
      end

      it 'library_location_zipcode should be nil' do
        expect(user.library_location_zipcode).to be_nil
      end
    end

    context 'with profile' do
      let(:library_location) { FactoryBot.create(:library_location) }
      let(:profile) { FactoryBot.build(:profile, library_location: library_location) }
      let(:user) { FactoryBot.create(:user, profile: profile) }

      it 'library_location_name should be correct' do
        expect(user.library_location_name).to eq(library_location.name)
      end

      it 'library_location_zipcode should be correct' do
        expect(user.library_location_zipcode).to eq(library_location.zipcode)
      end
    end
  end

  context 'library card login user' do
    let(:org) { FactoryBot.create(:organization, :library_card_login) }
    let(:other_org) { FactoryBot.create(:organization, :library_card_login) }
    let(:pin) { Array.new(4) { rand(10) }.join }
    let(:card_number) { Array.new(7) { rand(10) }.join }
    let(:user_params) do
      {
        library_card_number: card_number,
        library_card_pin: pin,
        organization_id: org.id,
        password: Digest::MD5.hexdigest(pin).first(10),
        password_confirmation: Digest::MD5.hexdigest(pin).first(10)
      }
    end

    it 'should be valid' do
      user = User.new(user_params)
      expect(user).to be_valid
    end

    it 'should strip whitespace from library card number' do
      whitespace_params = user_params.merge(library_card_number: '  1234567890  ')
      user = User.new(whitespace_params)
      user.save
      expect(user.reload.library_card_number).to eq('1234567890')
    end

    it 'should be invalid with duplicate library card number' do
      User.create(user_params)
      user2 = User.new(user_params)
      expect(user2).to_not be_valid
    end

    it 'should be invalid with duplicate library card number plus whitespace' do
      User.create(user_params)
      user2 = User.new(user_params.merge(library_card_number: " #{card_number} "))
      expect(user2).to_not be_valid
    end

    it 'should be valid with duplicate card number at another organization' do
      User.create(user_params)
      user2 = User.new(user_params.merge(organization_id: other_org.id))
      expect(user2).to be_valid
    end
  end

  context 'case insensitive login' do
    let!(:user1) { FactoryBot.create(:user, email: 'downcase@gmail.com') }
    it 'should not allow two emails with upppercased and downcased one' do
      user2 = FactoryBot.build(:user, email: 'Downcase@gmail.com')
      expect(user2.valid?).to be_falsey
    end
  end

  context 'phone number user' do
    let(:org) { create(:organization, phone_number_users_enabled: true) }

    it 'should be valid with valid phone number and org' do
      user = User.new(phone_number: '1231231234', organization: org)
      expect(user).to be_valid
    end

    describe 'invalid phone number' do
      subject { User.new(phone_number: '1231234', organization: org) }

      it 'should be invalid with invalid phone number' do
        expect(subject).not_to be_valid
      end

      it 'should have correct error message' do
        subject.valid?
        expect(subject.errors[:phone_number]).to contain_exactly('must be exactly 10 digits')
      end
    end
  end
end
