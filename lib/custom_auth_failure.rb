class CustomAuthFailure < Devise::FailureApp
  protected

    def i18n_options(options)
      options.merge(subsite_auth_keys)
    end

  private

    def subsite_auth_keys
      {
        authentication_keys: User.human_attribute_name(organization.authentication_key_field, { locale: I18n.locale }),
        password_keys: User.human_attribute_name(organization.password_key_field, { locale: I18n.locale })
      }
    end

    def subdomain
      request.subdomain
    end

    def organization
      Organization.find_by(subdomain: subdomain) || Organization.first
    end
end
