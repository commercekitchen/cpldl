require "rails_helper"

describe CoursesHelper do
  describe "#humanize_pub_status" do
    it "returns the full name for a given status" do
      course = FactoryGirl.create(:course)
      course.pub_status = "D"
      expect(helper.humanize_pub_status(course)).to eq("Draft")
      course.pub_status = "P"
      expect(helper.humanize_pub_status(course)).to eq("Published")
      course.pub_status = "T"
      expect(helper.humanize_pub_status(course)).to eq("Trashed")
    end
  end
end
