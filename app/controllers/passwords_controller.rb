# frozen_string_literal: true

class PasswordsController < Devise::PasswordsController
  before_action :skip_authorization
end
