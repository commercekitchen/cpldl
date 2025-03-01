class AddAssociationIndices < ActiveRecord::Migration[5.2]
  def change
    # Users
    add_foreign_key :users, :programs
    add_index :users, :program_id
    add_foreign_key :users, :schools
    add_index :users, :school_id

    # Profiles
    add_foreign_key :profiles, :users
    add_index :profiles, :user_id
    add_foreign_key :profiles, :library_locations
    add_index :profiles, :library_location_id

    # Course Progresses
    add_foreign_key :course_progresses, :courses
    add_index :course_progresses, :course_id
    add_foreign_key :course_progresses, :users
    add_index :course_progresses, :user_id

    # Lesson Completions
    add_foreign_key :lesson_completions, :course_progresses
    add_index :lesson_completions, :course_progress_id
  end
end
