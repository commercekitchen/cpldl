# frozen_string_literal: true

module Admin
  module Custom
    class TranslationsController < Admin::Custom::BaseController
      include TranslationsHelper

      before_action :find_locale
      before_action :retrieve_key, only: %i[create update]
      before_action :find_translation, only: %i[edit update]

      def index
        authorize current_organization, :customize?
        @translations = Translation.locale(@locale)
      end

      def new
        authorize current_organization, :customize?
        @translation = Translation.new(locale: @locale, key: params[:key])
      end

      def create
        authorize current_organization, :customize?
        @translation = Translation.new(translation_params)
        if @translation.value == default_translation_value
          flash[:alert] = 'Your new translation is the same as the default.'
          render :new
        elsif @translation.save
          flash[:success] = "Text for #{translation_keys(@locale)[@key]} updated."
          I18n.backend.reload!
          redirect_to admin_custom_translations_url(@locale)
        else
          render :new
        end
      end

      def edit
        authorize current_organization, :customize?
      end

      def update
        authorize current_organization, :customize?

        if @translation.update(translation_params)
          flash[:notice] = "Text for #{translation_keys(@locale)[@key]} updated."
          I18n.backend.reload!
          redirect_to admin_custom_translations_url(@locale)
        else
          render :edit
        end
      end

      def destroy
        authorize current_organization, :customize?

        Translation.destroy(params[:id])
        I18n.backend.reload!
        redirect_to admin_custom_translations_url(@locale)
      end

      private

      def find_locale
        @locale = I18n.locale # params[:locale_id]
      end

      def find_translation
        @translation = Translation.find(params[:id])
      end

      def retrieve_key
        @key = params[:i18n_backend_active_record_translation][:key]
      end

      def translation_params
        params.require(:i18n_backend_active_record_translation).permit(:locale,
                                                                       :key, :value)
      end

      def default_translation_value
        I18n.t(@translation.key, locale: @locale)
      end
    end
  end
end
