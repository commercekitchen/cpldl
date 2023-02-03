# frozen_string_literal: true

class PhoneNumberStrategy < Warden::Strategies::Base
  include ApplicationHelper

  def valid?
    phone_number.present?
  end

  def authenticate!
    user = User.find_or_create_by(phone_number: phone_number, organization: current_organization)

    if user.valid?
      user.add_role(:user, current_organization)
      success!(user)
    else
      fail!(user.errors.full_messages.join(','))
    end
  end

  private

  def phone_number
    params[:phone_number][:phone].delete('^0-9')
  end
end
