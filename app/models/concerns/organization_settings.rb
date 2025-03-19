# frozen_string_literal: true

module OrganizationSettings
  extend ActiveSupport::Concern

  included do
    store_accessor :preferences,
                   :footer_logo_file_name,
                   :footer_logo_file_size,
                   :footer_logo_link,
                   :footer_logo_content_type,
                   :user_survey_enabled,
                   :user_survey_link,
                   :spanish_survey_link,
                   :custom_certificate_enabled,
                   :phone_number_users_enabled,
                   :custom_recommendation_survey,
                   :custom_topics,
                   :survey_required,
                   :deidentify_reports
  end

  # Define methods with type enforcement and default values
  def footer_logo_file_name
    preferences['footer_logo_file_name'].to_s
  end

  def footer_logo_file_size
    preferences['footer_logo_file_size'].to_i
  end

  def footer_logo_link
    preferences['footer_logo_link'].to_s
  end

  def footer_logo_content_type
    preferences['footer_logo_content_type'].to_s
  end

  def user_survey_enabled
    ActiveModel::Type::Boolean.new.cast(preferences['user_survey_enabled']) || false
  end
  alias user_survey_enabled? user_survey_enabled

  def custom_certificate_enabled
    ActiveModel::Type::Boolean.new.cast(preferences['custom_certificate_enabled']) || false
  end
  alias custom_certificate_enabled? custom_certificate_enabled

  def phone_number_users_enabled
    ActiveModel::Type::Boolean.new.cast(preferences['phone_number_users_enabled']) || false
  end
  alias phone_number_users_enabled? phone_number_users_enabled

  def custom_recommendation_survey
    ActiveModel::Type::Boolean.new.cast(preferences['custom_recommendation_survey']) || false
  end
  alias custom_recommendation_survey? custom_recommendation_survey

  def custom_topics
    ActiveModel::Type::Boolean.new.cast(preferences['custom_topics']) || false
  end
  alias custom_topics? custom_topics

  def survey_required
    ActiveModel::Type::Boolean.new.cast(preferences['survey_required']) || false
  end
  alias survey_required? survey_required

  def deidentify_reports
    ActiveModel::Type::Boolean.new.cast(preferences['deidentify_reports']) || false
  end
  alias deidentify_reports? deidentify_reports
end
