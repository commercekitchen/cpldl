# frozen_string_literal: true

class AddIndexToLessonCompletionsLessonIdAndCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :lesson_completions, [:lesson_id, :created_at],
              name: 'index_lesson_completions_on_lesson_id_and_created_at'
  end
end
