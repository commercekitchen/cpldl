unless Rails.env.test? || Rails.env.production?
  options = { forward_emails_to:
    ["joe+staging-digitallearn@commercekitchen.com",
      "jamie+staging-digitallearn@commercekitchen.com",
      "tom+staging-digitallearn@commercekitchen.com",
      "alex+dl@commercekitchen.com"] }
  interceptor = MailInterceptor::Interceptor.new(options)
  ActionMailer::Base.register_interceptor(interceptor)
end
