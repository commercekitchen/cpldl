class AddContribExtensionsForSearch < ActiveRecord::Migration
  if Rails.env.development? || Rails.env.test?
    def up
      execute 'CREATE EXTENSION pg_trgm;'
      execute 'CREATE EXTENSION fuzzystrmatch;'
    end
  end
end
