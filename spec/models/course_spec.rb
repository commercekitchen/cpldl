require "rails_helper"

describe Course do

  context "verify validations" do

    before(:each) do
      @course = FactoryGirl.build(:course, language: FactoryGirl.create(:language))
    end

    it "is initially valid" do
      expect(@course).to be_valid
    end

    it "should not allow two courses with the same title" do
      @course.save
      @course2 = FactoryGirl.build(:course, language: FactoryGirl.create(:language))
      expect(@course2).to_not be_valid
      expect(@course2.errors.full_messages.first).to eq("Title has already been taken")
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

    it "should not require the seo page title" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "seo page title cannot be longer than 90 chars" do
      valid_title = (0...90).map { ('a'..'z').to_a[rand(26)] }.join
      @course.seo_page_title = valid_title
      expect(@course).to be_valid

      invalid_title = (0...91).map { ('a'..'z').to_a[rand(26)] }.join
      @course.seo_page_title = invalid_title
      expect(@course).to_not be_valid
    end

    it "should not require the meta description" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "meta description cannot be longer than 156 chars" do
      valid_meta = (0...156).map { ('a'..'z').to_a[rand(26)] }.join
      @course.meta_desc = valid_meta
      expect(@course).to be_valid

      invalid_meta = (0...157).map { ('a'..'z').to_a[rand(26)] }.join
      @course.meta_desc = invalid_meta
      expect(@course).to_not be_valid
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
