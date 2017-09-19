before "deploy:starting", "rollbar:set_env"

namespace :rollbar do
  # I want the rollbar_token to exist in the secrets to be consistant.
  # The problem is that the rollbar commands to tell that a new deploy
  # went out are in the capistrano script, which doesn't have access to the
  # Rails env.  So, instead just pull the value of of the yml.

  desc "Set Rollbar notification variables"
  task :set_env do
    ROLLBAR_TOKEN = YAML.load_file(File.expand_path("config/secrets.yml"))["default"]["rollbar_api_key"]
    set :rollbar_token, ROLLBAR_TOKEN
    set :rollbar_env, proc { fetch :stage }
    set :rollbar_role, proc { :app }
  end
end
