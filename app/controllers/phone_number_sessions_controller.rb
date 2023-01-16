# frozen_string_literal: true

class PhoneNumberSessionsController < ApplicationController
  before_action :skip_authorization

  def new
  end

  def create
    phone_number = params[:phone_number].gsub(/\D/, '')

    # Validate phone number?
  end

  def destroy
  end
end
