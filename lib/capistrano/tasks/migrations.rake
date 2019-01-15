namespace :deploy do

  desc 'Runs rake data:migrate if migrations are set'
  Rake::Task['deploy:migrate'].clear_actions
  task migrate: [:set_rails_env] do
    on fetch(:migration_servers) do
      conditionally_migrate = fetch(:conditionally_migrate)
      info '[deploy:migrate] Checking changes in db' if conditionally_migrate

      if conditionally_migrate && test(:diff, "-qr #{release_path}/db #{current_path}/db")
        info '[deploy:migrate] Skip `deploy:migrate` (nothing changed in db)'
      else
        info '[deploy:migrate] Run `rake db:migrate:with_data`'
        invoke :'deploy:migrating_with_data'
      end
    end
  end

end