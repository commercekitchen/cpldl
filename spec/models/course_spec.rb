require "rails_helper"

describe Course do

  context "verify validations" do

    before(:each) do
      @course = FactoryGirl.build(:course, language: FactoryGirl.create(:language))
    end

    it "is initially valid" do
      expect(@course).to be_valid
    end

    it "can only have listed statuses" do
      allowed_statuses = %w(P D T)
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

    it "should initially be set to draft status" do
      expect(@course.pub_status).to eq("D")
    end

  end

  context "#topics_list" do

    before(:each) do
      @course = FactoryGirl.create(:course, language: FactoryGirl.create(:language))
      @topic = FactoryGirl.create(:topic, title: "Existing Topic")
    end

    it "assigns topics to a course" do
      topics = ["Topic 1", "Topic2"]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it "skips blank topics when assigning to a course" do
      topics = ["Topic 1", "Topic2", ""]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it "adds new topics to the list, if not previously there" do
      topics = ["Topic 1", "Topic2", "Topic3", ""]
      @course.topics_list(topics)
      expect(Topic.count).to eq(4) # The exising + the 3 non-empty topics.
    end

    it "does nothing if the topics list is blank" do
      topics = nil
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)

      topics = []
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(0)
    end

  end

end
