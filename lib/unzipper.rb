class Unzipper

  def initialize(asl_package, parent_dir = nil)
    @parent_dir = parent_dir || Rails.root
    @package = asl_package
  end

  def unzip_lesson
    unless @package.blank?
      unzip_and_upload_asl
      # TODO: clear temporary zip location
    end
  end

  private

  def unzip_and_upload_asl
    Zip::File.open(zip_file) do |file|
      file.each do |f|
        S3Store.new.save(body: f.get_input_stream.read, key: s3_object_path(f))
      end
    end
  end

  def zip_file
    @zip_file ||= File.join(Rails.root, "#{import_path}/original/#{package_file_name}.zip")
  end

  def s3_object_path(file)
    "#{storyline_path}/#{package_file_name}/#{file.name}"
  end

  def package_file_name
    @package_file_name ||= @package.instance.story_line_file_name.chomp(".zip")
  end

  def import_path
    @import_path ||= "public/system/lessons/story_lines/#{@package.instance.id}"
  end

  def storyline_path
    @storyline_path ||= "storylines/#{@package.instance.id}"
  end

end
