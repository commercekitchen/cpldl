# frozen_string_literal: true

module Api
  module V1
    class CmsPagesController < Api::V1::BaseController
      def show
        cms_page = CmsPage.friendly.find(params[:id])
        skip_authorization
        render json: {
          slug: cms_page.slug,
          title: cms_page.title,
          body: cms_page.body,
          seo_page_title: cms_page.seo_page_title,
          meta_desc: cms_page.meta_desc
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Page not found" }, status: :not_found
      end
    end
  end
end
