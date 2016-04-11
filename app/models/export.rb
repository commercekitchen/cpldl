require "csv"

class Export < ActiveRecord::Base
  def self.to_csv_for_completion_report(data)
    binding.pry
    CSV.generate do |csv|
      csv << ["Zip Code", "Sign-Ups(total)", "Course Title", "Completions"]
      data.each do |zip_code, info|
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
end
