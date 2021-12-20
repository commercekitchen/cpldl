Recaptcha.configure do |config|
  config.site_key  = Rails.application.credentials[Rails.env.to_sym][:recaptcha_site_key]
  config.secret_key = Rails.application.credentials[Rails.env.to_sym][:recaptcha_secret_key]
end
