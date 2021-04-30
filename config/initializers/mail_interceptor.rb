if Rails.env.staging?
  class MailInterceptor
    def self.delivering_email(message)
      allowed_domains = /@ckdtech.co$|@commercekitchen.com$|@annealinc.com$/i
      recipients = Array(message.to).select { |recipient| (recipient =~ allowed_domains).present? }

      # If filtered recipients doesn't include any acceptable
      # recipient, auto populate with some employees
      recipients = %w[tom@ckdtech.co alex@ckdtech.co] if recipients.empty?

      message.to = recipients
    end
  end

  ActionMailer::Base.register_interceptor(MailInterceptor)
end