class FixLessonBug < ActiveRecord::Migration
  def change
    u = User.all
    u.each do |u|
      course = u.course_progresses.find_by(course_id: 23)
      if course.nil?
        next
      else
        bad_apple = u.course_progresses.find_by(course_id: 23).completed_lessons.find_by(lesson_id: 95)
      end

      if bad_apple.nil?
        next
      else
        bad_apple.destroy
      end
    end
  end
end
