# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController

    def index
      @categories = policy_scope(Category)
      @new_category = current_organization.categories.new
      authorize @new_category, :create?

      enable_sidebar
    end

    def create
      @category = current_organization.categories.create(category_params)
      authorize @category

      respond_to do |format|
        format.html do
          redirect_to action: 'index'
        end

        format.js {}
      end
    end

    def sort
      categories = policy_scope(Category)
      SortService.sort(model: categories, order_params: params[:order], attribute_key: :category_order, user: current_user)

      head :ok
    end

    def toggle
      @category = Category.find(params[:category_id])
      authorize @category, :update?

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
