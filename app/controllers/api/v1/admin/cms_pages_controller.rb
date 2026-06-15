# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CmsPagesController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          cms_pages = policy_scope(CmsPage).includes(:language)
          render json: { cms_pages: cms_pages.map { |p| page_list_payload(p) } }
        end

        def show
          cms_page = current_organization.cms_pages.friendly.find(params[:id])
          authorize cms_page, :update?
          render json: { cms_page: page_detail_payload(cms_page), options: form_options }
        end

        def form_options_action
          authorize CmsPage.new(organization: current_organization), :create?
          render json: { options: form_options }
        end

        def create
          cms_page = current_organization.cms_pages.new(cms_page_params)
          cms_page.subdomain = current_organization.subdomain
          authorize cms_page

          cms_page.set_pub_date if cms_page.pub_status == 'P'

          if cms_page.save
            render status: :created, json: { cms_page: page_detail_payload(cms_page) }
          else
            render status: :unprocessable_entity, json: { errors: cms_page.errors.full_messages }
          end
        end

        def update
          cms_page = current_organization.cms_pages.friendly.find(params[:id])
          authorize cms_page, :update?

          new_params = cms_page_params
          cms_page.slug = nil if cms_page.title != new_params[:title]

          old_pub_status = cms_page.pub_status
          cms_page.assign_attributes(new_params)
          cms_page.update_pub_date(cms_page.pub_status) unless cms_page.pub_status == old_pub_status

          if cms_page.save
            render json: { cms_page: page_detail_payload(cms_page.reload) }
          else
            render status: :unprocessable_entity, json: { errors: cms_page.errors.full_messages }
          end
        end

        def destroy
          cms_page = current_organization.cms_pages.friendly.find(params[:id])
          authorize cms_page

          cms_page.destroy
          head :no_content
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def page_list_payload(page)
          {
            id: page.id,
            slug: page.slug,
            title: page.title,
            pub_status: page.pub_status,
            audience: page.audience,
            language: page.language&.name
          }
        end

        def page_detail_payload(page)
          {
            id: page.id,
            slug: page.slug,
            title: page.title,
            language_id: page.language_id,
            body: page.body,
            audience: page.audience,
            author: page.author,
            pub_status: page.pub_status,
            pub_date: page.pub_date&.strftime('%Y-%m-%d'),
            seo_page_title: page.seo_page_title,
            meta_desc: page.meta_desc
          }
        end

        def form_options
          { languages: Language.all.map { |l| { id: l.id, name: l.name } } }
        end

        def cms_page_params
          params.require(:cms_page).permit(
            :title, :language_id, :body, :audience, :author,
            :pub_status, :pub_date, :seo_page_title, :meta_desc
          )
        end
      end
    end
  end
end
