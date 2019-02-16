class Unzipper

  def initialize(asl_package, parent_dir=nil)
    @parent_dir = parent_dir || Rails.root
    @package = asl_package
  end

  def unzip_lesson
    unless @package.blank?
      clear_directory
      unzip_asl
    end
  end

  private

    def clear_directory
      FileUtils.rm_rf(storyline_path)
    end

    def unzip_asl
      Zip::File.open(zip_file) do |file|
        file.each do |f|
          f_path = File.join(unzip_destination, f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          file.extract(f, f_path)
        end
      end
    end

    def zip_file
      @zip_file ||= File.join(Rails.root, "#{import_path}/original/#{package_file_name}.zip")
    end

    def unzip_destination
      @unzip_destination ||= File.join(storyline_path, package_file_name)
    end

    def package_file_name
      @package_file_name ||= @package.instance.story_line_file_name.chomp(".zip")
    end

    def import_path
      @import_path ||= "public/system/lessons/story_lines/#{@package.instance.id}"
    end

    def storyline_path
      @storyline_path ||= File.join(@parent_dir, "public/storylines/#{@package.instance.id}")
    end

end
