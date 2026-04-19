# frozen_string_literal: true

module Api
  module V1
    module Admin
      class FooterLinksController < ::Api::V1::BaseController
        before_action :require_admin

        def create
          link = current_organization.footer_links.build(footer_link_params)
          if link.save
            render json: link_payload(link), status: :created
          else
            render status: :unprocessable_entity, json: { errors: link.errors.full_messages }
          end
        end

        def destroy
          link = current_organization.footer_links.find(params[:id])
          link.destroy
          head :no_content
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def footer_link_params
          params.require(:footer_link).permit(:label, :url, :language_id)
        end

        def link_payload(link)
          { id: link.id, label: link.label, url: link.url, languageId: link.language_id, languageName: link.language&.name }
        end
      end
    end
  end
end
