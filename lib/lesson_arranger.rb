class LessonArranger


  def initialize(lesson)
    @lesson = lesson
    @course = lesson.course
    assign_assessment_order
  end

  

end