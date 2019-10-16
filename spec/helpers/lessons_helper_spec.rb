# frozen_string_literal: true

require 'rails_helper'

describe LessonsHelper do

  let(:lesson) { FactoryBot.create(:lesson) }

  describe '#asl_iframe' do
    it 'includes lesson summary as title' do
      expect(helper.asl_iframe(lesson)).to match("title=\"#{lesson.summary}\"")
    end
  end

end
