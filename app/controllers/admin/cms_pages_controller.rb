module Admin
  class CmsPagesController < BaseController
    before_action :set_page, only: [:show, :edit, :update, :destroy]
    before_action :set_maximums, only: [:new, :edit]

    def index
      @pages = CmsPages.all
    end

    def show
    end

    def new
      @page = CmsPage.new
    end

    def create
      @page = CmsPage.create(cms_page_params)

      if params[:cms_page][:pub_status] == "P"
        @page.set_pub_date
      end

      if @page.save
        if params[:commit] == "Save Page"
          redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully created."
        else
          redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully created, now edit the Spanish version."
        end
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @page.update(cms_page_params)
        redirect_to edit_admin_cms_page_path(@page), notice: "Page was successfully updated."
      else
      end
    end

    # def destroy
    # end

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
                                       :content,
                                       :published,
                                       :seo_page_title,
                                       :seo_meta_desc)
    end
  end
end