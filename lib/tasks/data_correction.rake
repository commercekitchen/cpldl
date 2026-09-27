# frozen_string_literal: true

namespace :data_correction do
  desc 'add branches flag to existing orgs'
  task add_branches: :environment do
    Organization.all.each do |organization|
      if organization.subdomain == 'www'
        organization.update!(branches: false)
      else
        organization.update!(branches: true)
      end
    end
  end

  desc 'Backfill CourseProgress#completed_at for progress rows where every lesson is already ' \
       'complete. Course completion used to require finishing the assessment lesson specifically; ' \
       'it now requires every lesson, so historical rows that were fully finished under the old ' \
       'rule but never touched the assessment lesson were never stamped complete.'
  task backfill_course_progress_completed_at: :environment do
    updated = 0

    CourseProgress.where(completed_at: nil).find_each do |course_progress|
      next unless course_progress.all_lessons_completed?

      completed_at = course_progress.lesson_completions.maximum(:created_at) || Time.zone.now
      course_progress.update!(completed_at: completed_at)
      updated += 1
    end

    puts "Backfilled completed_at for #{updated} course progress record(s)."
  end
end
