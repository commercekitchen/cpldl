require "csv"

class Export < ActiveRecord::Base
  def self.to_csv_for_completion_report(data)
    @data = data
    if @data[:version] == "zip"
      generate_csv_for_zip
    elsif @data[:version] == "lib"
      generate_csv_for_lib
    end
  end

  def self.generate_csv_for_zip
    @data.delete(:version)
    CSV.generate do |csv|
      csv << ["Zip Code", "Sign-Ups(total)", "Course Title", "Completions"]
      @data.each do |zip_code, info|
        zip_code = zip_code
        sign_ups = info[:sign_ups]

        values = [zip_code, sign_ups]
        csv.add_row values

        info[:completions].each do |k, v|
          course_title = k
          completions = v
          more_values = ["", "", course_title, completions]
          csv.add_row more_values
        end
      end
    end
  end

  def self.generate_csv_for_lib
    @data.delete(:version)
    CSV.generate do |csv|
      csv << ["Library", "Sign-Ups(total)", "Course Title", "Completions"]
      @data.each do |library, info|
        library  = library
        sign_ups = info[:sign_ups]

        values = [library, sign_ups]
        csv.add_row values

        info[:completions].each do |k, v|
          course_title = k
          completions = v
          more_values = ["", "", course_title, completions]
          csv.add_row more_values
        end
      end
    end
  end
end
