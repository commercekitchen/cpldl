module Admin
  class CmsPagesController < BaseController
    before_action :set_page, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]

    def index
      @pages = CmsPage.all
    end

    def show
    end

    def new
      @page = CmsPage.new
    end

    def create
      @page = CmsPage.new(cms_page_params)
      binding.pry
      if params[:commit] == "Preview Page"
        render :new
      elsif params[:commit] == "Save Page"
        if params[:cms_page][:pub_status] == "P"
          @page.set_pub_date
        end

        if @page.save
          redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully created."
        else
          render :new
        end
      else
        if @page.save
          redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully created, now edit the Spanish version."
        else
          render :new
        end
      end
    end

    def edit
    end

    def update
      @page.slug = nil #slug must be set to nil for friendly ID to update

      if params[:cms_page][:pub_status] != @page.pub_status
        @page.update_pub_date(params[:cms_page][:pub_status])
      end

      if @page.update(cms_page_params)
        if params[:commit] == "Save Page"
          redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully updated."
        else
          redirect_to new_admin_cms_page_path, notice: "Page was successfully updated."
        end
      else
        render :edit
      end
    end

    def sort
      params[:order].each do |_k, v|
        CmsPage.find(v[:id]).update_attribute(:cms_page_order, v[:position])
      end

      render nothing: true
    end

    def destroy
      if @page.destroy
        redirect_to admin_dashboard_index_path, notice: "Page was successfully deleted."
      else
        render :edit
      end
    end

  private

    def set_page
      @page = CmsPage.friendly.find(params[:id])
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
                 contents_attributes: [:cms_page_id,
                                       :body,
                                       :language_id,
                                       :_destroy])
    end
  end
end