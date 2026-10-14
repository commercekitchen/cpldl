require "csv"

org = Organization.find_by(subdomain: 'www')
start_date = Date.parse("1/7/2026")
end_date = Date.parse("1/10/2026")

lessons_csv = CSV.generate do |out|
  out << %w[course_id lesson_id course_publication_status att_provided_course completion_count]
  lessons = Lesson.joins(:course).where(courses: { organization_id: org.id })
  lessons.find_each do |l|
    completions = LessonCompletion.where(lesson_id: l.id).where('created_at >= ? AND created_at < ?', start_date, end_date).count
    pub_status = Course.pub_status_options.rassoc(l.course.pub_status)&.first
    out << [l.course.friendly_id, l.friendly_id, pub_status, l.course.new_course?, completions]
  end
end

courses_csv = CSV.generate do |out|
  out << %w[course_id course_publication_status att_provided_course completion_count]
  courses = Course.where(organization_id: org.id)
  courses.find_each do |c|
    completions = CourseProgress.completed.where(course_id: c.id).where('completed_at >= ? AND completed_at < ?', start_date, end_date).count
    pub_status = Course.pub_status_options.rassoc(c.pub_status)&.first
    out << [c.friendly_id, pub_status, c.new_course?, completions]
  end
end

s3 = Aws::S3::Client.new(region: Rails.application.config.s3_region)
lessons_key = "exports/#{org.subdomain}-lesson-completions-q3.csv"
courses_key = "exports/#{org.subdomain}-course-completions-q3.csv"
s3.put_object(bucket: Rails.application.config.s3_bucket_name, key: lessons_key, body: lessons_csv)
s3.put_object(bucket: Rails.application.config.s3_bucket_name, key: courses_key, body: courses_csv)

# Either download with `aws s3 cp s3://<bucket>/<key> .`, or get a temporary link:
Aws::S3::Presigner.new(client: s3).presigned_url(:get_object, bucket: Rails.application.config.s3_bucket_name, key: lessons_key, expires_in: 3600)
Aws::S3::Presigner.new(client: s3).presigned_url(:get_object, bucket: Rails.application.config.s3_bucket_name, key: courses_key, expires_in: 3600)
