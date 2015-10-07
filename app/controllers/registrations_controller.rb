class RegistrationsController < Devise::RegistrationsController

    # extend create to send email
  def create
    super
    if @user.persisted?
      ProjectOutcomeMailer.new_registration(@user).deliver_later
    end
  end
end
