# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
# :token also covers the signed report download links (ReportExportToken).
Rails.application.config.filter_parameters += %i[password reset_password_token token]
