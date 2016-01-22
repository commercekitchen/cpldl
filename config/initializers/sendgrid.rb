# Initialize ActionMailer settings for sendgrid

login = Rails.application.secrets.sendgrid_login
password = Rails.application.secrets.sendgrid_password
domain = Rails.application.secrets.sendgrid_domain || "digitallearn.org"

if login.nil? and password.nil?
  abort('Please ensure the sendgrid_login and sendgrid_password are defined in secrets.yml')
else
  ActionMailer::Base.smtp_settings = {
    :user_name => login,
    :password => password,
    :domain => domain,
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
