# frozen_string_literal: true

module Admin
  class LibraryLocationsController < BaseController
    before_action :enable_sidebar

    def index
      @library_locations = current_organization.library_locations
    end

    def new
      @library_location = current_organization.library_locations.build
    end

    def create
      @library_location = current_organization.library_locations.build(library_location_params)
      if @library_location.save
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully created.'
      else
        render :new
      end
    end

    def edit
      @library_location = LibraryLocation.find(params[:id])
    end

    def update
      @library_location = LibraryLocation.find(params[:id])
      if @library_location.update(library_location_params)
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @library_location = LibraryLocation.find(params[:id])
      if @library_location.destroy
        redirect_to admin_library_locations_path, notice: 'Library Branch was successfully deleted.'
      else
        redirect_to admin_library_locations_path, alert: 'Sorry, we were unable to remove this library branch.'
      end
    end

    def sort
      params[:order].each_value do |v|
        LibraryLocation.find(v[:id]).update_attribute(:sort_order, v[:position])
      end
      render nothing: true
    end

    private

    def library_location_params
      params.require(:library_location).permit(:name, :zipcode)
    end
  end
end
