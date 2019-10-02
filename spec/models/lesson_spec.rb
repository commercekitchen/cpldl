# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#  pub_status              :string
#  parent_lesson_id        :integer
#  parent_id               :integer
#

require "rails_helper"

describe Lesson do

  let(:course) { FactoryGirl.create(:course_with_lessons) }

  context "validations" do

    before(:each) do
      @lesson = FactoryGirl.create(:lesson)
    end

    it "initially it is valid" do
      expect(@lesson).to be_valid
    end

  end

  context "scopes" do

    context ".published" do

      it "returns all published lessons" do
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.second, course.lessons.third)
      end

      it "returns all published lessons" do
        course.lessons.second.update(pub_status: "D")
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.third)
      end

      it "returns all published lessons" do
        course.lessons.second.update(pub_status: "A")
        expect(course.lessons.published).to contain_exactly(course.lessons.first, course.lessons.third)
      end

    end

    context ".copied_from_lesson" do

      let(:new_org) { FactoryGirl.create(:organization) }
      let(:new_course) { FactoryGirl.create(:course_with_lessons, organization: new_org) }
      let(:original_lesson) { course.lessons.first }
      let(:copied_lesson) { new_course.lessons.first }

      before(:each) do
        original_lesson.propagation_org_ids << new_org.id
        copied_lesson.update(parent_id: original_lesson.id)
      end

      it "returns all copied lessons" do
        expect(Lesson.copied_from_lesson(original_lesson)).to include(copied_lesson)
      end

      it "does not return non-copied lessons" do
        expect(Lesson.copied_from_lesson(original_lesson).count).to eq(1)
      end

    end

  end

  context "#published_lesson_order" do

    it "returns the order of only published lessons" do
      course.lessons.second.update(pub_status: "D")
      expect(course.lessons.first.published_lesson_order).to eq 1
      expect(course.lessons.second.published_lesson_order).to eq 0
      expect(course.lessons.third.published_lesson_order).to eq 2
    end

  end

  context "#propagates_org_ids" do
    it "is empty by default" do
      expect(Lesson.new.propagation_org_ids).to eq([])
    end

    it "can be updated" do
      lesson = Lesson.new
      lesson.propagation_org_ids = [1]
      expect(lesson.propagation_org_ids).to eq([1])
    end
  end
end
