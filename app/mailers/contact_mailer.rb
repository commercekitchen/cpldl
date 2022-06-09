# frozen_string_literal: true

class ContactMailer < ApplicationMailer

  def email(contact_id)
    to = 'pla@ala.org'
    subject = 'New DigitalLearn.org Contact Form Submitted'
    @contact = Contact.find(contact_id)
    mail(to: to, subject: subject)
  end

end
