# frozen_string_literal: true

namespace :data_correction do
  desc 'add branches flag to existing orgs'
  task add_branches: :environment do
    Organization.all.each do |organization|
      if organization.subdomain == 'www'
        organization.update_attributes!(branches: false)
      else
        organization.update_attributes!(branches: true)
      end
    end
  end
end
