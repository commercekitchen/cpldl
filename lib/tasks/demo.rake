# frozen_string_literal: true

namespace :demo do
  desc 'duplicate courses so that they show up on the demo site'
  task add_courses: :environment do
    courses = Course.where_exists(:organization, subdomain: 'chipublib')
    courses.each do |cpl_course|
      @new_course = Course.create(title: cpl_course.title,
                                  course_order: cpl_course.course_order,
                                  seo_page_title: cpl_course.seo_page_title,
                                  meta_desc: cpl_course.meta_desc,
                                  summary: cpl_course.summary,
                                  description: cpl_course.description,
                                  contributor: cpl_course.contributor,
                                  pub_status: cpl_course.pub_status,
                                  language_id: cpl_course.language_id,
                                  level: cpl_course.level,
                                  notes: cpl_course.notes,
                                  format: cpl_course.format,
                                  pub_date: cpl_course.pub_status == 'P' ? Time.zone.today : nil)

      @new_course.organization = Organization.find(3)

      cpl_course.topics.each do |topic|
        @new_course.topics << topic
      end

      cpl_course.attachments.each do |attachment|
        new_attachment = attachment.dup
        @new_course.attachments << new_attachment
      end

      cpl_course.lessons.each do |cpl_lesson|
        new_lesson = Lesson.create(title: cpl_lesson.title,
                                   duration: cpl_lesson.duration,
                                   course_id: @new_course.id,
                                   lesson_order: cpl_lesson.lesson_order,
                                   summary: cpl_lesson.summary,
                                   story_line: cpl_lesson.story_line,
                                   seo_page_title: cpl_lesson.seo_page_title,
                                   meta_desc: cpl_lesson.meta_desc,
                                   is_assessment: cpl_lesson.is_assessment,
                                   story_line_file_name: cpl_lesson.story_line_file_name,
                                   story_line_content_type: cpl_lesson.story_line_content_type,
                                   story_line_file_size: cpl_lesson.story_line_file_size,
                                   story_line_updated_at: cpl_lesson.story_line_updated_at,
                                   pub_status: cpl_lesson.pub_status,
                                   parent_id: cpl_lesson.id)

        @new_course.lessons << new_lesson
      end
    end
  end

  desc 'duplicate courses so that they show up on the demo site'
  task remove_courses: :environment do
    courses = Course.where_exists(:organization, subdomain: 'demo')
    courses.each do |course|
      course.lessons.each(&:destroy)
      course.destroy
    end
  end
end
