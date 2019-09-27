# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#  subsite_course :boolean          default(FALSE)
#  parent_id      :integer
#  display_on_dl  :boolean          default(FALSE)
#  category_id    :integer
#

require "rails_helper"

describe Course do

  context "validations" do

    let(:org) { create(:organization) }
    before(:each) do
      @course = FactoryBot.build(:course, organization: org)
      @draft_course = FactoryBot.create(:draft_course)
    end

    it "is initially valid" do
      expect(@course).to be_valid
    end

    it "should not allow two courses with the same title within organization" do
      existing_course = FactoryBot.create(:course, title: @course.title, organization: org)
      @course.validate

      expect(@course.errors.messages.empty?).to be(false)
      expect(@course.errors.messages[:title].first).to eq("has already been taken for the organization")
    end

    it "can only have listed statuses" do
      allowed_statuses = %w(P D A)
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

    it "can only have listed formats" do
      allowed_formats = %w(D M)
      allowed_formats.each do |format|
        @course.format = format
        expect(@course).to be_valid
      end

      @course.format = ""
      expect(@course).to_not be_valid

      @course.format = nil
      expect(@course).to_not be_valid

      @course.format = "Y"
      expect(@course).to_not be_valid
    end

    it "should initially be set to published status" do
      expect(@draft_course.pub_status).to eq("D")
    end

    it "does not set pub date if status is not Published" do
      expect(@draft_course.set_pub_date).to be(nil)
    end

    it "should set pub date on publication" do
      Timecop.freeze do
        @course.pub_status = "P"
        expect(@course.set_pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end

    it "should update the pub date with status change" do
      Timecop.freeze do
        @course.pub_status = "P"
        expect(@course.set_pub_date).to_not be(nil)
        @course.pub_status = "D"
        expect(@course.update_pub_date(@course.pub_status)).to be(nil)
        @course.pub_status = "P"
        expect(@course.update_pub_date(@course.pub_status).to_i).to be(Time.zone.now.to_i)
      end
    end

    it "humanizes publication status" do
      expect(@course.current_pub_status).to eq("Published")
      @course.pub_status = "D"
      expect(@course.current_pub_status).to eq("Draft")
      @course.pub_status = "T"
      expect(@course.current_pub_status).to eq("Trashed")
    end

    it "should not require the seo page title" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "seo page title cannot be longer than 90 chars" do
      valid_title = (0...90).map { ("a".."z").to_a[rand(26)] }.join
      @course.seo_page_title = valid_title
      expect(@course).to be_valid

      invalid_title = (0...91).map { ("a".."z").to_a[rand(26)] }.join
      @course.seo_page_title = invalid_title
      expect(@course).to_not be_valid
    end

    it "should not require the meta description" do
      @course.seo_page_title = ""
      expect(@course).to be_valid
    end

    it "meta description cannot be longer than 156 chars" do
      valid_meta = (0...156).map { ("a".."z").to_a[rand(26)] }.join
      @course.meta_desc = valid_meta
      expect(@course).to be_valid

      invalid_meta = (0...157).map { ("a".."z").to_a[rand(26)] }.join
      @course.meta_desc = invalid_meta
      expect(@course).to_not be_valid
    end

    it "should not allow the other topics value to be set without text" do
      @course.other_topic = nil
      @course.other_topic_text = ""
      expect(@course).to be_valid

      @course.other_topic = "1"
      @course.other_topic_text = ""
      expect(@course).to_not be_valid

      @course.other_topic = "1"
      @course.other_topic_text = "New topic"
      expect(@course).to be_valid
    end
  end

  context "#topics_list" do

    before(:each) do
      @course = FactoryBot.create(:course)
      @topic = FactoryBot.create(:topic, title: "Existing Topic")
    end

    it "assigns topics to a course" do
      topics = ["Topic 1", "Topic2"]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics.count).to eq(2)
    end

    it "returns a topic list as a string" do
      topics = ["Topic 1", "Topic 2"]
      @course.topics_list(topics)
      @course.reload
      expect(@course.topics_str).to eq("Topic 1, Topic 2")
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

  context "#next_lesson_id (from old version of next_lesson_id)" do

    before :each do
      @course = FactoryBot.create(:course_with_lessons)
    end

    it "should return the first lesson id if called without an id" do
      expect(@course.next_lesson_id).to be(@course.lessons.first.id)
    end

    it "should return the second lesson id if called with the first lesson id" do
      expect(@course.next_lesson_id(@course.lessons.first.id)).to be(@course.lessons.second.id)
    end

    it "should return the last lesson id if called with the last lesson id" do
      expect(@course.next_lesson_id(@course.lessons.last.id)).to be(@course.lessons.last.id)
    end

    it "should return the first lesson id if called with an invalid lesson id" do
      expect(@course.next_lesson_id(123)).to be(@course.lessons.first.id)
    end

    it "should raise an error if called when there are no lessons" do
      @course.lessons.destroy_all
      expect { @course.next_lesson_id }.to raise_error(StandardError)
    end

  end

  context "#next_lesson_id" do

    it "should raise an error if there are no lessons" do
      expect do
        @course = FactoryBot.create(:course)
        @course.next_lesson_id(@course.lessons.first.id)
      end.to raise_error StandardError
    end

    it "should return the id of the next lesson in order" do
      @course = FactoryBot.create(:course_with_lessons)
      expect(@course.next_lesson_id).to eq @course.lessons.first.id
      expect(@course.next_lesson_id(nil)).to eq @course.lessons.first.id
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.second.id
      expect(@course.next_lesson_id(@course.lessons.second.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

    it "should return the next lesson id, even if the lessons are out of order" do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.third.update(lesson_order: 5)
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.second.id
      expect(@course.next_lesson_id(@course.lessons.second.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

    it "should skip unpublished lessons" do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.second.update(pub_status: "D")
      @course.lessons.third.update(lesson_order: 5)
      expect(@course.next_lesson_id(@course.lessons.first.id)).to eq @course.lessons.third.id
      expect(@course.next_lesson_id(@course.lessons.third.id)).to eq @course.lessons.third.id
    end

  end

  context "#duration" do

    before :each do
      @course = FactoryBot.create(:course)
      @lesson1 = FactoryBot.create(:lesson, title: "1", duration: 75)
      @lesson2 = FactoryBot.create(:lesson, title: "2", duration: 150)
      @lesson3 = FactoryBot.create(:lesson, title: "3", duration: 225)
      @lesson4 = FactoryBot.create(:lesson, title: "4", duration: 90)
      @lesson5 = FactoryBot.create(:lesson, title: "5", duration: 9)
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration).to eq("7 mins")
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson4]
      expect(@course.duration).to eq("1 min")
    end

    it "should return the sum of the lesson durations" do
      @course.lessons << [@lesson5]
      expect(@course.duration).to eq("0 mins")
    end

    it "should return duration in format if one is passed" do
      @course.lessons << [@lesson1, @lesson2, @lesson3]
      expect(@course.duration("minutes")).to eq("7 minutes")
    end

    it "should not count draft lessons" do
      @course = FactoryBot.create(:course_with_lessons)
      @course.lessons.first.update(pub_status: "D")
      expect(@course.duration).to eq "3 mins" # 90 * 2 = 180 / 60 = 3 mins
    end

  end

end
