# Initialize ActionMailer settings for sendgrid

api_key = Rails.application.secrets.sendgrid_api_key
domain = Rails.application.secrets.sendgrid_domain || "chipublib.digitallearn.org"

if login.nil? and password.nil?
  abort('Please ensure the sendgrid_login and sendgrid_password are defined in secrets.yml')
else
  ActionMailer::Base.smtp_settings = {
    :user_name => 'apikey',
    :password => api_key,
    :domain => domain,
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
