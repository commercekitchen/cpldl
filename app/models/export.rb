# frozen_string_literal: true

require 'csv'

class Export
  def self.to_csv_for_completion_report(data)
    @data = data
    case @data.delete(:version)
    when 'zip_code'
      generate_csv_for_zip
    when 'library'
      generate_csv_for_lib
    when 'survey_responses'
      generate_csv_for_survey_responses
    when 'partner'
      generate_csv_for_partner
    end
  end

  def self.generate_csv_for_partner
    CSV.generate do |csv|
      csv << ['Partner', 'Sign-Ups(total)', 'Course Title', 'Completions']
      @data.each do |partner, data|
        csv.add_row [partner, data[:sign_ups]]

        data[:completions].each do |k, v|
          csv.add_row ['', '', k, v]
        end
      end
    end
  end

  def self.generate_csv_for_zip
    CSV.generate do |csv|
      csv << ['Zip Code', 'Sign-Ups(total)', 'Course Title', 'Completions']
      @data.each do |zip_code, info|
        sign_ups = info[:sign_ups]

        values = [zip_code, sign_ups]
        csv.add_row values

        info[:completions].each do |k, v|
          course_title = k
          completions = v
          more_values = ['', '', course_title, completions]
          csv.add_row more_values
        end
      end
    end
  end

  def self.generate_csv_for_lib
    CSV.generate do |csv|
      csv << ['Library', 'Sign-Ups(total)', 'Course Title', 'Completions']
      @data.each do |library, info|
        library_name = if library.present?
                         LibraryLocation.find(library).name
                       else
                         'Unknown'
                       end

        sign_ups = info[:sign_ups]

        values = [library_name, sign_ups]
        csv.add_row values

        info[:completions].each do |k, v|
          course_title = k
          completions = v
          more_values = ['', '', course_title, completions]
          csv.add_row more_values
        end
      end
    end
  end

  def self.generate_csv_for_survey_responses
    CSV.generate do |csv|
      csv << ['How comfortable are you with desktop or laptop computers?',
              'How comfortable are you using a phone, tablet, or iPad to access the Internet?',
              'What would you like to do with a computer?',
              'Total Responses',
              'Course Title',
              'Completions']
      @data.each do |responses_hash, count_data|
        csv_row = [I18n.t("quiz.set_one_#{responses_hash['set_one']}"),
                   I18n.t("quiz.set_two_#{responses_hash['set_two']}"),
                   I18n.t("quiz.set_three_#{responses_hash['set_three']}"),
                   count_data[:responses]]

        csv.add_row csv_row

        count_data[:completions].each do |k, v|
          course_title = k
          completions = v
          more_values = ['', '', '', '', course_title, completions]
          csv.add_row more_values
        end
      end
    end
  end
end
