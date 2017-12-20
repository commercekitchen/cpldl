module Admin
  class LibraryLocationsController < BaseController
    def index
      @library_locations = current_organization.library_locations.unscoped.order(:sort_order)
      render layout: "admin/base_with_sidebar"
    end

    def new
      @library_location = current_organization.library_locations.build
    end

    def create
      @library_location = current_organization.library_locations.build

      if @library_location.errors.any?
        render :new
      else @library_location.update(library_location_params)
        redirect_to admin_library_locations_path, notice: "Library Branch was successfully created."
      end
    end

    def edit
      @library_location = LibraryLocation.find(params[:id])
    end

    def update
      @library_location = LibraryLocation.find(params[:id])
      if @library_location.update(library_location_params)
        redirect_to admin_library_locations_path, notice: "Library Branch was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @library_location = LibraryLocation.find(params[:id])
      if @library_location.destroy
        redirect_to admin_library_locations_path, notice: "Library Branch was successfully deleted."
      else
        redirect_to admin_library_locations_path, alert: "Sorry, we were unable to remove this library branch."
      end
    end

    def sort
      params[:order].each do |_k, v|
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
