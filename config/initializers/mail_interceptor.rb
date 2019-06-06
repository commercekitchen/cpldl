unless Rails.env.test? || Rails.env.production?
  options = { forward_emails_to:
    ["joe+stagingdl@ckdtech.co",
      "susie+stagingdl@ckdtech.co",
      "ming+stagingdl@ckdtech.co"] }
  interceptor = MailInterceptor::Interceptor.new(options)
  ActionMailer::Base.register_interceptor(interceptor)
end
