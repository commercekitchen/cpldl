# frozen_string_literal: true

require 'rails_helper'

describe LessonsHelper do

  let(:lesson) { FactoryBot.create(:lesson) }
  let(:child_lesson) { FactoryBot.create(:lesson_without_story, parent: lesson) }
  let(:no_storyline_lesson) { FactoryBot.create(:lesson_without_story) }

  describe '#asl_iframe' do
    it 'includes lesson summary as title' do
      expect(helper.asl_iframe(lesson)).to match("title=\"#{lesson.summary}\"")
    end

    it 'creates iframe from child lesson with no storyline file' do
      expect(helper.asl_iframe(child_lesson)).to have_selector('iframe')
    end

    it 'does not create iframe from non-child lesson with no storyline file' do
      expect(helper.asl_iframe(no_storyline_lesson)).to_not have_selector('iframe')
    end
  end

end
