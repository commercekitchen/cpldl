# frozen_string_literal: true

require 'csv'

namespace :data_import do
  desc 'Import branch data for an organization'
  task :import_branches, [:subdomain] => :environment do |t, args|
    subdomain = args[:subdomain]
    missing_subdomain_error = "You must provide a subdomain argument to import"\
      " branches: `rake data_import:import_branches[subdomain]`"
    abort(missing_subdomain_error) unless subdomain.present?

    organization = Organization.find_by(subdomain: subdomain)
    abort("Subsite #{subdomain} does not exist") unless organization.present?

    filename = Rails.root.join("lib", "tasks", "data_import", "branch_data", "#{subdomain}.csv")
    abort("File not found: #{filename}") unless File.exist?(filename)

    count = 0
    CSV.foreach(filename, headers: true) do |row|
      count += 1
      branch = organization.library_locations.find_or_create_by!(row.to_hash)
      branch.update(sort_order: count - 1)
    end

    puts "Imported #{count} branches"
  end
end
