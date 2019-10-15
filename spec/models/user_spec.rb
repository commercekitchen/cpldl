# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  email                         :string           default("")
#  encrypted_password            :string           default(""), not null
#  reset_password_token          :string
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0), not null
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :string
#  last_sign_in_ip               :string
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  confirmation_sent_at          :datetime
#  unconfirmed_email             :string
#  failed_attempts               :integer          default(0), not null
#  unlock_token                  :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  profile_id                    :integer
#  quiz_modal_complete           :boolean          default(FALSE)
#  invitation_token              :string
#  invitation_created_at         :datetime
#  invitation_sent_at            :datetime
#  invitation_accepted_at        :datetime
#  invitation_limit              :integer
#  invited_by_id                 :integer
#  invited_by_type               :string
#  invitations_count             :integer          default(0)
#  token                         :string
#  organization_id               :integer
#  school_id                     :integer
#  program_location_id           :integer
#  acting_as                     :string
#  library_card_number           :string
#  student_id                    :string
#  date_of_birth                 :datetime
#  grade                         :integer
#  quiz_responses_object         :text
#  program_id                    :integer
#  encrypted_library_card_pin    :string
#  encrypted_library_card_pin_iv :string
#

require 'rails_helper'

describe User do
  context '#tracking_course?' do

    before(:each) do
      @user = create(:user)
      @course1 = create(:course, title: 'Course 1')
      @course2 = create(:course, title: 'Course 2')
      @course_progress1 = create(:course_progress, user: @user, course_id: @course1.id, tracked: true)
      @course_progress2 = create(:course_progress, user: @user, course_id: @course2.id, tracked: false)
      # @user.course_progresses << [@course_progress1, @course_progress2]
    end

    it 'should return true for a tracked course' do
      expect(@user.tracking_course? @course1.id).to be true
    end

    it 'should return false for an un-tracked course' do
      expect(@user.tracking_course? @course2.id).to be false
    end

  end

  context '#completed_lesson_ids' do

    before(:each) do
      @user = FactoryBot.create(:user)
      @course1 = FactoryBot.create(:course, title: 'Course 1')
      @course_progress1 = FactoryBot.create(:course_progress, course_id: @course1.id, tracked: true)
      @course_progress1.completed_lessons.create({ lesson_id: 1 })
      @course_progress1.completed_lessons.create({ lesson_id: 2 })
      @course_progress1.completed_lessons.create({ lesson_id: 5 })
      @course2 = FactoryBot.create(:course, title: 'Course 2')
      @course_progress2 = FactoryBot.create(:course_progress, course_id: @course2.id, tracked: true)
      @course_progress2.completed_lessons.create({ lesson_id: 3 })
      @course_progress2.completed_lessons.create({ lesson_id: 4 })
      @course_progress2.completed_lessons.create({ lesson_id: 6 })
      @course3 = FactoryBot.create(:course, title: 'Course 3')
      @course_progress3 = FactoryBot.create(:course_progress, course_id: @course3.id, tracked: true)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
    end

    it 'should return an array of all completed lesson ids for the course' do
      expect(@user.completed_lesson_ids(@course1.id)).to eq([1, 2, 5])
      expect(@user.completed_lesson_ids(@course2.id)).to eq([3, 4, 6])
    end

    it 'should return an empty array if the user has not completed any lessons' do
      expect(@user.completed_lesson_ids(@course3.id)).to eq([])
    end

    it 'should return an empty array if the user has not started the course' do
      expect(@user.completed_lesson_ids(123)).to eq([])
    end

  end

  context '#completed_course_ids' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @course1 = FactoryBot.create(:course, title: 'Course 1')
      @course2 = FactoryBot.create(:course, title: 'Course 2')
      @course3 = FactoryBot.create(:course, title: 'Course 3')
    end

    it 'should return an array of all completed course ids' do
      now = Time.zone.now
      @course_progress1 = FactoryBot.create(:course_progress, course_id: @course1.id, tracked: true, completed_at: now)
      @course_progress2 = FactoryBot.create(:course_progress, course_id: @course2.id, tracked: true)
      @course_progress3 = FactoryBot.create(:course_progress, course_id: @course3.id, tracked: true, completed_at: now)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
      expect(@user.completed_course_ids).to include(@course1.id, @course3.id)
      expect(@user.completed_course_ids.count).to be(2)
    end

    it 'should return an empty array if the user has not completed any lessons' do
      expect(@user.completed_course_ids).to eq([])
    end
  end

  context 'user information' do
    before(:each) do
      @user = FactoryBot.create(:user)
    end

    it 'returns current_roles' do
      @user.add_role(:admin)
      expect(@user.current_roles).to eq('admin')
    end

    it 'returns preferred language' do
      @user.profile = FactoryBot.create(:profile, user: @user, language: FactoryBot.create(:language))
      expect(@user.preferred_language).to eq('English')
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
    let(:pin) { Array.new(4) { rand(10) }.join }
    let(:user_params) do
      {
        library_card_number: Array.new(7) { rand(10) }.join,
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

    it 'should be valid for second user' do
      User.create(user_params)
      user2 = User.new(user_params.merge(library_card_number: Array.new(7) { rand(10) }.join))
      expect(user2).to be_valid
      expect(user2.save).to be_truthy
    end
  end

  context '#add_user_token' do
    it 'assigns a random user token' do
      @user = FactoryBot.create(:user)
      expect(@user.token).to_not be(nil)

      @user2 = FactoryBot.create(:user, email: 'random@nowhere.com')
      expect(@user.token).to_not eq(@user2.token)
    end
  end

  context 'case insensitive login' do
    let!(:user1) { FactoryBot.create(:user, email: 'downcase@gmail.com') }
    it 'should not allow two emails with upppercased and downcased one' do
      user2 = FactoryBot.build(:user, email: 'Downcase@gmail.com')
      expect(user2.valid?).to be_falsey
    end
  end
end
