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

end
