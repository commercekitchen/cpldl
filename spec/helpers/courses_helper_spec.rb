require "rails_helper"

describe CoursesHelper do

  before(:each) do
    @course = FactoryGirl.create(:course)
  end

  describe "#pub_status_str" do
    it "returns the full name for a given status" do
      @course.pub_status = "D"
      expect(helper.pub_status_str(@course)).to eq("Draft")
      @course.pub_status = "P"
      expect(helper.pub_status_str(@course)).to eq("Published")
      @course.pub_status = "T"
      expect(helper.pub_status_str(@course)).to eq("Trashed")
    end
  end

  describe "#percent_complete" do

    before(:each) do
      @course2 = FactoryGirl.create(:course, title: "Course 2")
      @user = FactoryGirl.create(:user)
      sign_in @user
      @course_progress = FactoryGirl.create(:course_progress, course_id: @course.id)
      @user.course_progresses << @course_progress
    end

    it "returns an empty string if the user isn't logged in" do
      sign_out @user
      expect(helper.percent_complete(@course)).to eq("")
    end

    it "returns an empty string if the user doesnt have a course progress for the course" do
      expect(helper.percent_complete(@course2)).to eq("")
    end

    it "returns the course progress" do
      expect(helper.percent_complete(@course)).to eq("0% complete")
    end
  end
end
