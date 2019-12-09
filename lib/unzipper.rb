# frozen_string_literal: true

class Unzipper

  def initialize(asl_package, parent_dir = nil)
    @parent_dir = parent_dir || Rails.root
    @package = asl_package
  end

  def unzip_lesson
    if @package.present?
      unzip_and_upload_asl
    end
  end

  private

  def unzip_and_upload_asl
    Zip::File.open(zip_file) do |zip_file|
      update_javascript(zip_file)
      zip_file.each do |file|
        LessonStore.new.save(file: file, key: object_path(file), acl: 'public-read', zip_file: zip_file)
      end
    end
  end

  def update_javascript(zip_file)
    js_file_location = 'story_content/user.js'
    user_js = zip_file.read(js_file_location)
    dlc_transition_string = "getDLCTransition('lesson')"
    old_event_string = 'window.parent.sendLessonCompletedEvent()'
    new_event_string = 'window.parent.postMessage("lesson_completed", "*")'
    new_contents = user_js.gsub(dlc_transition_string, new_event_string).gsub(old_event_string, new_event_string)
    zip_file.get_output_stream(js_file_location) { |f| f.puts new_contents }
    zip_file.commit
  rescue Errno::ENOENT
    Rails.logger.info('No user.js file found')
  end

  def zip_file
    @zip_file ||= Rails.root.join(import_path, 'original', "#{package_file_name}.zip")
  end

  def object_path(file)
    "#{storyline_path}/#{package_file_name}/#{file.name}"
  end

  def package_file_name
    @package_file_name ||= @package.instance.story_line_file_name.chomp('.zip')
  end

  def storyline_zip_dir
    'public/system/lessons/story_lines'
  end

  def import_path
    @import_path ||= "#{storyline_zip_dir}/#{@package.instance.id}"
  end

  def storyline_path
    @storyline_path ||= "storylines/#{@package.instance.id}"
  end

end
