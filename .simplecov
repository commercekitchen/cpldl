SimpleCov.start "rails" do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Lib", "app/lib"
  add_group "Routing", "config/routes"
  add_group "Views", "app/views"

  add_filter "models/ckeditor"
end
