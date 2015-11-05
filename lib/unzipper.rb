class Unzipper
  def initialize(asl_package)
    @file = asl_package
    package_prepper unless @file.blank?
  end

  def package_prepper
    file_name   = @file.instance.story_line_file_name.chomp(".zip")
    import_path = "public/system/lessons/story_lines/#{@file.instance.id}"
    public_path = "public/storylines/#{@file.instance.id}"
    zip_file    = File.join(Rails.root, "#{import_path}/original/#{file_name}.zip")
    dest_path   = File.join(Rails.root, "#{public_path}/#{file_name}")
    unzip_asl(zip_file, dest_path)
  end

  def unzip_asl(zip_file, dest_path)
    Zip::File.open(zip_file) do |file|
      file.each do |f|
        f_path = File.join(dest_path, f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
  end
end
