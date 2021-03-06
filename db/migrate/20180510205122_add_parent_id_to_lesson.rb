class AddParentIdToLesson < ActiveRecord::Migration[4.2]
  def change
    add_column :lessons, :parent_id, :integer, index: true
    add_index :lessons, :parent_id

    # This should be unnecessary in a development environment.
    # It should have been implemented as a data migration when it was needed.
    # backfill_lessons
  end

  def backfill_lessons
    Lesson.unscoped.joins(course: :organization).where.not(organizations: {subdomain: 'www'}).find_each do |lesson|
      parent_course = Course.find_by(id: lesson.course.parent_id)

      if parent_course
        base_lesson = parent_course.lessons.find_by(title: lesson.title) || parent_course.lessons.find_by(summary: lesson.summary)
        lesson.update(parent_id: base_lesson.id) if base_lesson.present?
      end
    end
  end
end
