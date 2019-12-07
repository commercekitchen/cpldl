# frozen_string_literal: true

module Admin
  class CmsPagesController < BaseController
    before_action :set_page, only: %i[show edit update destroy]
    before_action :set_maximums, only: %i[new edit]

    def show; end

    def new
      @cms_page = CmsPage.new
    end

    def create
      @cms_page = CmsPage.new(cms_page_params)
      if params[:commit] == 'Preview Page'
        @cms_page_body = @cms_page.body.html_safe
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

    def edit; end

    def update_pub_status
      cms_page            = CmsPage.find(params[:cms_page_id])
      cms_page.pub_status = params[:value]
      cms_page.update_pub_date(params[:value])

      if cms_page.save
        render status: :ok, json: cms_page.pub_status.to_s
      else
        render status: :unprocessable_entity, json: 'post failed to update'
      end
    end

    def update
      @pub_status = params[:cms_page][:pub_status]

      # slug must be set to nil for friendly ID to update
      @cms_page.slug = nil if @cms_page.title != params[:cms_page][:title]
      if params[:commit] == 'Preview Page'
        @cms_page_body = @cms_page.body.html_safe
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
      SortService.sort(model: CmsPage, order_params: params[:order], attribute_key: :cms_page_order)

      head :ok
    end

    def destroy
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

    def set_maximums
      @max_title = CmsPage.validators_on(:title).first.options[:maximum]
      @max_seo   = CmsPage.validators_on(:seo_page_title).first.options[:maximum]
      @max_meta  = CmsPage.validators_on(:meta_desc).first.options[:maximum]
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
                                       :seo_meta_desc,
                                       :organization_id)
    end
  end
end
