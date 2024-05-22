# frozen_string_literal: true

require 'csv'

class Export
  def self.to_csv_for_completion_report(data, organization = nil)
    @data = data
    case @data.delete(:version)
    when 'zip_code'
      generate_csv_for_zip
    when 'library'
      generate_csv_for_lib
    when 'survey_responses'
      generate_csv_for_survey_responses(organization)
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

  def self.generate_csv_for_survey_responses(organization)
    translation_prefix = organization&.custom_recommendation_survey ? "course_recommendation_survey.#{organization.subdomain}" : "course_recommendation_survey.default"

    CSV.generate do |csv|
      csv << [I18n.t("#{translation_prefix}.desktop.question"),
              I18n.t("#{translation_prefix}.mobile.question"),
              I18n.t("#{translation_prefix}.topics.question"),
              'Total Responses',
              'Course Title',
              'Completions']
      @data.each do |responses_hash, count_data|
        topic = Topic.find_by(id: responses_hash['topic'])
        topic_translation_key = topic&.translation_key || 'none'
        csv_row = [I18n.t("#{translation_prefix}.desktop.#{responses_hash['desktop_level']&.downcase}"),
                   I18n.t("#{translation_prefix}.mobile.#{responses_hash['mobile_level']&.downcase}"),
                   I18n.t("#{translation_prefix}.topics.#{topic_translation_key}"),
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
