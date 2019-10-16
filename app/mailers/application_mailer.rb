# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@digitallearn.org'
  layout 'mailer'
end
