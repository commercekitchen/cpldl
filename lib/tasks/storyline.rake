# frozen_string_literal: true

namespace :storyline do
  desc 'Re-unzip storyline archives for specific lesson IDs, normalizing known ' \
       'Storyline directory names (story_content, html5, etc.) to their canonical ' \
       "lowercase casing. Use for lessons whose zips arrived with re-cased folders " \
       '(e.g. mangled by a translation vendor) that break on case-sensitive S3. ' \
       'Usage: LESSON_IDS=5412,5413 rake storyline:normalize_known_dirs'
  task normalize_known_dirs: :environment do
    ids = ENV.fetch('LESSON_IDS', '').split(',').map(&:strip).reject(&:blank?).map(&:to_i)
    abort 'Set LESSON_IDS=1,2,3' if ids.empty?

    ids.each do |lesson_id|
      lesson = Lesson.find(lesson_id)
      puts "Lesson #{lesson.id}: re-unzipping with known-directory-name normalization..."
      UnzipStorylineJob.new.perform(lesson.id, normalize_known_dirs: true)
      puts "Lesson #{lesson.id}: done, storyline_unzip_status=#{lesson.reload.storyline_unzip_status}"
    rescue StandardError => e
      puts "Lesson #{lesson_id}: FAILED - #{e.class}: #{e.message}"
    end
  end
end
