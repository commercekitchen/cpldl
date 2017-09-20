# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  def email
    ContactMailer.email(Contact.last)
  end
end
