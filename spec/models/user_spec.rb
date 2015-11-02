require "rails_helper"

describe User do

  context "#tracking_course?" do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @course1 = FactoryGirl.create(:course, title: "Course 1")
      @course2 = FactoryGirl.create(:course, title: "Course 2")
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true)
      @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: false)
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
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true, completed_at: Time.zone.now)
      @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: true)
      @course_progress3 = FactoryGirl.create(:course_progress, course_id: @course3.id, tracked: true, completed_at: Time.zone.now)
      @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
      expect(@user.completed_course_ids).to eq([@course1.id, @course3.id])
    end

    it "should return an empty array if the user has not completed any lessons" do
      expect(@user.completed_course_ids).to eq([])
    end

  end

end
