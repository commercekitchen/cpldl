# frozen_string_literal: true

module Admin
  class LibraryLocationsController < BaseController
    before_action :enable_sidebar

    def index
      @library_locations = policy_scope(LibraryLocation)
    end

    def new
      @library_location = current_organization.library_locations.build
      authorize @library_location
    end

    def create
      @library_location = current_organization.library_locations.build(library_location_params)
      authorize @library_location

      if @library_location.save
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully created.'
      else
        render :new
      end
    end

    def edit
      @library_location = LibraryLocation.find(params[:id])
      authorize @library_location
    end

    def update
      @library_location = LibraryLocation.find(params[:id])
      authorize @library_location

      if @library_location.update(library_location_params)
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @library_location = LibraryLocation.find(params[:id])
      authorize @library_location

      if @library_location.destroy
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully deleted.'
      else
        redirect_to admin_library_locations_path, alert: 'Sorry, we were unable to remove this library branch.'
      end
    end

    def sort
      SortService.sort(model: LibraryLocation, order_params: params[:order], attribute_key: :sort_order, user: current_user)

      head :ok
    end

    private

    def library_location_params
      params.require(:library_location).permit(:name, :zipcode)
    end
  end
end
