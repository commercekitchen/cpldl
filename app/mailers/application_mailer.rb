# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'DigitalLearn <no-reply@digitallearn.org>'
  layout 'mailer'
end
