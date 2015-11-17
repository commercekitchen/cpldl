module Admin
  class CmsPagesController < BaseController
    before_action :set_page, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]

    def show
    end

    def new
      @cms_page = CmsPage.new
      @cms_page.contents.build
    end

    def create
      @cms_page = CmsPage.new(cms_page_params)
      if params[:commit] == "Preview Page"
        render :new
      elsif params[:commit] == "Save Page"
        if params[:cms_page][:pub_status] == "P"
          @cms_page.set_pub_date
        end

        if @cms_page.save
          redirect_to edit_admin_cms_page_path(@cms_page), notice: "Page was successfully created."
        else
          render :new
        end
      end
    end

    def edit
    end

    def update
      @cms_page.slug = nil # slug must be set to nil for friendly ID to update
      if params[:commit] == "Preview Page"
        render :new
      else
        if params[:cms_page][:pub_status] != @cms_page.pub_status
          @cms_page.update_pub_date(params[:cms_page][:pub_status])
        end

        if @cms_page.update(cms_page_params)
          redirect_to edit_admin_cms_page_path(@cms_page), notice: "Page was successfully updated."
        else
          render :edit
        end
      end
    end

    def sort
      params[:order].each do |_k, v|
        CmsPage.find(v[:id]).update_attribute(:cms_page_order, v[:position])
      end

      render nothing: true
    end

    def destroy
      if @cms_page.destroy
        redirect_to admin_dashboard_index_path, notice: "Page was successfully deleted."
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
                                       :page_type,
                                       :audience,
                                       :author,
                                       :pub_status,
                                       :pub_date,
                                       :seo_page_title,
                                       :seo_meta_desc,
                 contents_attributes: [:id, [:cms_page_id,
                                             :body,
                                             :language_id,
                                             :_destroy]])
    end
  end
end
