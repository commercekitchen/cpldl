require "rails_helper"

describe Course do

  context "verify validations" do

    before(:each) do
      @course = FactoryGirl.build(:course)
    end

    it "is initially valid" do
      expect(@course).to be_valid
    end

    it "can only have listed statuses" do
      allowed_statuses = ["P"]
      allowed_statuses.each do |status|
        @course.pub_status = status
        expect(@course).to be_valid
      end

      @course.pub_status = ""
      expect(@course).to_not be_valid

      @course.pub_status = nil
      expect(@course).to_not be_valid

      @course.pub_status = "X"
      expect(@course).to_not be_valid
    end

    pending "the status should be set by default"

  end

end
