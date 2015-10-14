require "rails_helper"

describe Lesson do

  context "verify validations" do

    before(:each) do
      @lesson = FactoryGirl.create(:lesson)
    end

    it "initially it is valid" do
      expect(@lesson).to be_valid
    end

  end

end
