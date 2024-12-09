class DoorkeeperApplication < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken

  def redirect_uri_valid?(uri)
    redirect_host = URI(uri).host

    return true if Rails.env.development?

    redirect_host.ends_with?('training.digitallearn.org') || super
  end
end