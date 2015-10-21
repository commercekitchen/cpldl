require "rails_helper"

describe CoursesHelper do
  describe "#pub_status_str" do
    it "returns the full name for a given status" do
      course = FactoryGirl.create(:course)
      course.pub_status = "D"
      expect(helper.pub_status_str(course)).to eq("Draft")
      course.pub_status = "P"
      expect(helper.pub_status_str(course)).to eq("Published")
      course.pub_status = "T"
      expect(helper.pub_status_str(course)).to eq("Trashed")
    end
  end
end
