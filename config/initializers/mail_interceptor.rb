options = { forward_emails_to: ['jen+staging-digitallearn@commercekitchen.com',
                                'jamie+staging-digitallearn@commercekitchen.com',
                                'tom+staging-digitallearn@commercekitchen.com']}

unless (Rails.env.test? || Rails.env.production?)
  interceptor = MailInterceptor::Interceptor.new(options)
  ActionMailer::Base.register_interceptor(interceptor)
end
