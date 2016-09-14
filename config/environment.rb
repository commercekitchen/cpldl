# Load the Rails application.
require File.expand_path('../application', __FILE__)


# Initialize the Rails application.
Rails.application.initialize!


Rails.application.configure do

  config.chicago = false

  # Default
  config.subdomain_site = "www"
end