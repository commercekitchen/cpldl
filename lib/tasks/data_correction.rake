# frozen_string_literal: true

namespace :data_correction do
  desc 'add branches flag to existing orgs'
  task add_branches: :environment do
    Organization.all.each do |organization|
      if organization.subdomain == 'www'
        organization.update!(branches: false)
      else
        organization.update!(branches: true)
      end
    end
  end
end
