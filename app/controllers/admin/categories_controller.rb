module Admin
  class CategoriesController < BaseController

    def index
      @categories = current_organization.categories
      @new_category = current_organization.categories.new

      render layout: "admin/base_with_sidebar"
    end

    def create
      @category = current_organization.categories.create(category_params)

      respond_to do |format|
        format.html do
          redirect_to action: "index"
        end

        format.js {}
      end
    end

    def sort
      params[:order].each do |_k, v|
        Category.find(v[:id]).update_attribute(:category_order, v[:position])
      end

      render nothing: true
    end

    def toggle
      @category = Category.find(params[:category_id])
      currently_enabled = @category.enabled?
      @category.update(enabled: !currently_enabled)

      respond_to do |format|
        format.html do
          redirect_to action: "index"
        end

        format.js {}
      end
    end

    private

    def category_params
      params.require(:category).permit(:name)
    end
  end
end