# frozen_string_literal: true

module Api
  module V1
    class CourseRecommendationSurveysController < Api::V1::BaseController
      before_action :require_authenticated_user!
      before_action :require_recommendations_authorized!

      # GET /api/v1/course_recommendation_survey
      # Returns a JSON description of the survey: questions, types, and i18n'd labels.
      def show
        render json: survey_payload
      end

      # POST /api/v1/course_recommendation_survey
      # Accepts { desktop_level:, mobile_level:, topic: }, runs the recommendation
      # service, and persists quiz responses if the user hasn't answered before.
      def create
        current_user.update!(quiz_responses_object: quiz_params.to_h) if current_user.quiz_responses_object.blank?
        CourseRecommendationService.new(current_organization.id, quiz_params).add_recommended_courses(current_user.id)
        render json: { ok: true }
      end

      private

      def require_authenticated_user!
        unless current_user
          render status: :unauthorized, json: { message: 'You must be signed in.' }
        end
      end

      def require_recommendations_authorized!
        authorize current_organization, :get_recommendations?
      end

      def quiz_params
        params.permit(:desktop_level, :mobile_level, :topic)
      end

      # ──────────────────────────────────────────────────────────────────────
      # Survey payload builders
      # ──────────────────────────────────────────────────────────────────────

      def survey_payload
        {
          survey_required: current_organization.survey_required?,
          questions: survey_questions
        }
      end

      def survey_questions
        if current_organization.custom_recommendation_survey? && getconnected_survey?
          getconnected_questions
        else
          default_questions
        end
      end

      # The "getconnected" custom survey is identified by the org subdomain having
      # a matching partial — replicate the same lookup the legacy ERB does.
      def getconnected_survey?
        current_organization.subdomain == 'getconnected'
      end

      # ── Default survey ────────────────────────────────────────────────────

      def default_questions
        [
          desktop_level_question('default', %w[Beginner Intermediate Advanced Expert]),
          mobile_level_question('default', %w[Beginner Intermediate Advanced Expert]),
          default_topic_question
        ]
      end

      def default_topic_question
        topics = []
        default_topic_keys.each do |key|
          topic = Topic.find_by(translation_key: key)
          next unless topic

          topics << {
            value: topic.id.to_s,
            label: I18n.t("course_recommendation_survey.default.topics.#{key}")
          }
        end

        {
          key: 'topic',
          type: 'radio',
          text: I18n.t('course_recommendation_survey.default.topics.question'),
          options: topics
        }
      end

      def default_topic_keys
        %w[
          job_search
          education_child
          govt
          education_adult
          communication_social_media
          security
          software_apps
          information_searching
        ]
      end

      # ── GetConnected survey ───────────────────────────────────────────────

      def getconnected_questions
        [
          desktop_level_question('getconnected', %w[Beginner Intermediate Advanced]),
          mobile_level_question('getconnected', %w[Beginner Intermediate Advanced]),
          getconnected_topic_question
        ]
      end

      def getconnected_topic_question
        topic_map = [
          %w[education_adult     education_adult],
          %w[job_search          job_search],
          %w[education_child     education_child],
          %w[healthcare          healthcare],
          %w[telehealth          telehealth],
          %w[online_shopping     online_shopping],
          %w[online_billpay      online_billpay],
          %w[online_banking      online_banking],
          %w[online_classes      online_classes],
          %w[information_searching_1 information_searching],
          %w[information_searching_2 information_searching],
          %w[govt                govt],
          %w[communication_social_media communication_social_media],
          %w[software_apps       software_apps],
          %w[security            security]
        ]

        options = topic_map.filter_map do |question_key, topic_key|
          topic = Topic.for_organization(current_organization).find_by(translation_key: topic_key)
          next unless topic

          {
            value: topic.id.to_s,
            label: I18n.t("course_recommendation_survey.getconnected.topics.#{question_key}")
          }
        end

        # Append the "none" option with value "0"
        options << {
          value: '0',
          label: I18n.t('course_recommendation_survey.getconnected.topics.none')
        }

        {
          key: 'topic',
          type: 'radio',
          text: I18n.t('course_recommendation_survey.getconnected.topics.question'),
          options: options
        }
      end

      # ── Shared helpers ────────────────────────────────────────────────────

      def desktop_level_question(variant, levels)
        {
          key: 'desktop_level',
          type: 'radio',
          text: I18n.t("course_recommendation_survey.#{variant}.desktop.question"),
          options: level_options(variant, 'desktop', levels)
        }
      end

      def mobile_level_question(variant, levels)
        {
          key: 'mobile_level',
          type: 'radio',
          text: I18n.t("course_recommendation_survey.#{variant}.mobile.question"),
          options: level_options(variant, 'mobile', levels)
        }
      end

      def level_options(variant, device, levels)
        levels.map do |level|
          {
            value: level,
            label: I18n.t("course_recommendation_survey.#{variant}.#{device}.#{level.downcase}")
          }
        end
      end
    end
  end
end
