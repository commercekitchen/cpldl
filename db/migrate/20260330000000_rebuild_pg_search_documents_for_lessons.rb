# frozen_string_literal: true

class RebuildPgSearchDocumentsForLessons < ActiveRecord::Migration[5.2]
  def up
    PgSearch::Multisearch.rebuild(Lesson)
  end

  def down
    PgSearchDocument.where(searchable_type: 'Lesson').delete_all
  end
end
