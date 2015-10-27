require "rails_helper"

describe CourseProgress do

  context "#next_lesson" do

    before(:each) do
      @course1 = FactoryGirl.create(:course)
      @lesson2 = FactoryGirl.create(:lesson)
      @lesson3 = FactoryGirl.create(:lesson)
      @course1.lessons << [@lesson2, @lesson3]
      @course_progress = FactoryGirl.build(:course_progress, course_id: @course1.id)
    end

    it "should give lesson 1 when not started" do
      expect(@course_progress.next_lesson).to eq(1)
    end

    it "should give the next lesson number when started" do
      @course_progress.lessons_completed = 1
      expect(@course_progress.next_lesson).to eq(2)
    end

    it "should give the last lesson if course is complete" do
      @course_progress.lessons_completed = 3
      expect(@course_progress.next_lesson).to eq(3)
    end

  end

  context "#percent_complete" do

    before(:each) do
      @course1 = FactoryGirl.create(:course)
      @lesson2 = FactoryGirl.create(:lesson)
      @lesson3 = FactoryGirl.create(:lesson)
      @course1.lessons << [@lesson2, @lesson3]
      @course_progress = FactoryGirl.build(:course_progress, course_id: @course1.id)
    end

    it "should be 0 when not started" do
      expect(@course_progress.percent_complete).to eq(0)
    end

    it "should be 33 when 1 of 3 is completed" do
      @course_progress.lessons_completed = 1
      expect(@course_progress.percent_complete).to eq(33)
    end

    it "should be 100 when 3 of 3 are completed" do
      @course_progress.lessons_completed = 3
      expect(@course_progress.percent_complete).to eq(100)
    end

  end

end
