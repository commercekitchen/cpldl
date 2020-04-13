# frozen_string_literal: true

module Admin
  class CmsPagesController < BaseController
    before_action :set_page, only: %i[edit update destroy]

    def index
      @cms_pages = policy_scope(CmsPage)
      enable_sidebar
    end

    def new
      @cms_page = CmsPage.new(organization: current_organization)
      authorize @cms_page
    end

    def create
      @cms_page = CmsPage.new(cms_page_params.merge(organization: current_organization))
      authorize @cms_page

      if params[:commit] == 'Preview Page'
        @cms_page_body = unescaped_cms_content
        render :new
      elsif params[:commit] == 'Save Page'
        @cms_page.set_pub_date if params[:cms_page][:pub_status] == 'P'

        if @cms_page.save
          redirect_to edit_admin_cms_page_path(@cms_page), notice: 'Page was successfully created.'
        else
          render :new
        end
      end
    end

    def edit
      authorize @cms_page
    end

    def update_pub_status
      cms_page = CmsPage.find(params[:cms_page_id])
      authorize cms_page, :update?

      cms_page.pub_status = params[:value]
      cms_page.update_pub_date(params[:value])

      if cms_page.save
        render status: :ok, json: cms_page.pub_status.to_s
      else
        render status: :unprocessable_entity, json: 'post failed to update'
      end
    end

    def update
      authorize @cms_page

      @pub_status = params[:cms_page][:pub_status]

      # slug must be set to nil for friendly ID to update
      @cms_page.slug = nil if @cms_page.title != params[:cms_page][:title]
      if params[:commit] == 'Preview Page'
        @cms_page_body = unescaped_cms_content
        render :new
      else
        @cms_page.update_pub_date(@pub_status) unless @pub_status == @cms_page.pub_status

        if @cms_page.update(cms_page_params)
          redirect_to edit_admin_cms_page_path(@cms_page), notice: 'Page was successfully updated.'
        else
          render :edit
        end
      end
    end

    def sort
      pages = policy_scope(CmsPage)
      SortService.sort(model: pages, order_params: params[:order], attribute_key: :cms_page_order, user: current_user)

      head :ok
    end

    def destroy
      authorize @cms_page

      if @cms_page.destroy
        redirect_to admin_dashboard_index_path, notice: 'Page was successfully deleted.'
      else
        render :edit
      end
    end

    private

    def set_page
      @cms_page = CmsPage.friendly.find(params[:id])
    end

    def unescaped_cms_content
      @cms_page.body.html_safe
    end

    def cms_page_params
      params.require(:cms_page).permit(:title,
                                       :language_id,
                                       :body,
                                       :page_type,
                                       :audience,
                                       :author,
                                       :pub_status,
                                       :pub_date,
                                       :seo_page_title,
                                       :seo_meta_desc)
    end
  end
end
