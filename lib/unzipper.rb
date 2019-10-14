class Unzipper

  def initialize(asl_package, parent_dir = nil)
    @parent_dir = parent_dir || Rails.root
    @package = asl_package
  end

  def unzip_lesson
    unless @package.blank?
      unzip_and_upload_asl
    end
  end

  private

  def unzip_and_upload_asl
    Zip::File.open(zip_file) do |zip_file|
      zip_file.each do |file|
        LessonStore.new.save(file: file, key: object_path(file), acl: 'public-read', zip_file: zip_file)
      end
    end
  end

  def zip_file
    @zip_file ||= File.join(Rails.root, "#{import_path}/original/#{package_file_name}.zip")
  end

  def object_path(file)
    "#{storyline_path}/#{package_file_name}/#{file.name}"
  end

  def package_file_name
    @package_file_name ||= @package.instance.story_line_file_name.chomp(".zip")
  end

  def storyline_zip_dir
    @zip_dir ||= 'public/system/lessons/story_lines'
  end

  def import_path
    @import_path ||= "#{storyline_zip_dir}/#{@package.instance.id}"
  end

  def storyline_path
    @storyline_path ||= "storylines/#{@package.instance.id}"
  end

end
