# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  profile_id             :integer
#  quiz_modal_complete    :boolean          default(FALSE)
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#  subdomain              :string
#  token                  :string
#

require "rails_helper"

describe User do
  it { should belong_to(:organization) }

  context "#tracking_course?" do

    before(:each) do
      @user = create(:user)
      @course1 = create(:course, title: "Course 1")
      @course2 = create(:course, title: "Course 2")
      @course_progress1 = create(:course_progress, course_id: @course1.id, tracked: true)
      @course_progress2 = create(:course_progress, course_id: @course2.id, tracked: false)
      @user.course_progresses << [@course_progress1, @course_progress2]
    end

    it "should return true for a tracked course" do
      expect(@user.tracking_course? @course1.id).to be true
    end

    it "should return false for an un-tracked course" do
      expect(@user.tracking_course? @course2.id).to be false
    end

  end

  context "#completed_lesson_ids" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @course1 = FactoryGirl.create(:course, title: "Course 1")
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true)
      @course_progress1.completed_lessons.create({ lesson_id: 1 })
      @course_progress1.completed_lessons.create({ lesson_id: 2 })
      @course_progress1.completed_lessons.create({ lesson_id: 5 })
      @course2 = FactoryGirl.create(:course, title: "Course 2")
      @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: true)
      @course_progress2.completed_lessons.create({ lesson_id: 3 })
      @course_progress2.completed_lessons.create({ lesson_id: 4 })
      @course_progress2.completed_lessons.create({ lesson_id: 6 })
      @course3 = FactoryGirl.create(:course, title: "Course 3")
      @course_progress3 = FactoryGirl.create(:course_progress, course_id: @course3.id, tracked: true)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
    end

    it "should return an array of all completed lesson ids for the course" do
      expect(@user.completed_lesson_ids(@course1.id)).to eq([1, 2, 5])
      expect(@user.completed_lesson_ids(@course2.id)).to eq([3, 4, 6])
    end

    it "should return an empty array if the user has not completed any lessons" do
      expect(@user.completed_lesson_ids(@course3.id)).to eq([])
    end

    it "should return an empty array if the user has not started the course" do
      expect(@user.completed_lesson_ids(123)).to eq([])
    end

  end

  context "#completed_course_ids" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @course1 = FactoryGirl.create(:course, title: "Course 1")
      @course2 = FactoryGirl.create(:course, title: "Course 2")
      @course3 = FactoryGirl.create(:course, title: "Course 3")
    end

    it "should return an array of all completed course ids" do
      now = Time.zone.now
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true, completed_at: now)
      @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: true)
      @course_progress3 = FactoryGirl.create(:course_progress, course_id: @course3.id, tracked: true, completed_at: now)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
      expect(@user.completed_course_ids).to include(@course1.id, @course3.id)
      expect(@user.completed_course_ids.count).to be(2)
    end

    it "should return an empty array if the user has not completed any lessons" do
      expect(@user.completed_course_ids).to eq([])
    end
  end

  context "user information" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "returns current_roles" do
      @user.add_role(:admin)
      expect(@user.current_roles).to eq("admin")
    end

    it "returns preferred language" do
      @user.profile = FactoryGirl.create(:profile, language: FactoryGirl.create(:language))
      expect(@user.preferred_language).to eq("English")
    end
  end

  context "#add_user_token" do
    it "assigns a random user token" do
      @user = FactoryGirl.create(:user)
      expect(@user.token).to_not be(nil)

      @user2 = FactoryGirl.create(:user, email: "random@nowhere.com")
      expect(@user.token).to_not eq(@user2.token)
    end
  end
end
