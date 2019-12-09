# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController

    def index
      @categories = current_organization.categories
      @new_category = current_organization.categories.new

      enable_sidebar
    end

    def create
      @category = current_organization.categories.create(category_params)

      respond_to do |format|
        format.html do
          redirect_to action: 'index'
        end

        format.js {}
      end
    end

    def sort
      SortService.sort(model: Category, order_params: params[:order], attribute_key: :category_order)

      head :ok
    end

    def toggle
      @category = Category.find(params[:category_id])
      currently_enabled = @category.enabled?
      @category.update(enabled: !currently_enabled)

      respond_to do |format|
        format.html do
          redirect_to action: 'index'
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
