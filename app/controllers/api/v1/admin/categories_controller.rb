# frozen_string_literal: true

module Api
  module V1
    module Admin
      class CategoriesController < ::Api::V1::BaseController
        before_action :require_admin

        def index
          categories = current_organization.categories.unscoped
                                           .where(organization: current_organization)
                                           .order('enabled DESC, category_order ASC')

          render json: {
            categories: categories.map { |c| category_payload(c) }
          }
        end

        def create
          category = current_organization.categories.new(category_params)
          authorize category
          max_order = current_organization.categories.maximum(:category_order) || 0
          category.category_order = max_order + 1

          if category.save
            render status: :created, json: { category: category_payload(category) }
          else
            render status: :unprocessable_entity, json: { errors: category.errors.full_messages }
          end
        end

        def update
          category = current_organization.categories.find(params[:id])
          authorize category
          if category.update(category_params)
            render json: { category: category_payload(category) }
          else
            render status: :unprocessable_entity, json: { errors: category.errors.full_messages }
          end
        end

        def destroy
          category = current_organization.categories.find(params[:id])
          authorize category
          category.destroy
          head :no_content
        end

        def sort
          authorize Category.new(organization: current_organization), :update?
          ordered_ids = Array(params[:order])
          ordered_ids.each_with_index do |id, index|
            current_organization.categories.where(id: id).update_all(category_order: index + 1)
          end
          head :no_content
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def category_params
          params.require(:category).permit(:name)
        end

        def category_payload(category)
          {
            id: category.id,
            name: category.name,
            categoryOrder: category.category_order,
            enabled: category.enabled,
            courseCount: current_organization.courses.where(category_id: category.id).count
          }
        end
      end
    end
  end
end
