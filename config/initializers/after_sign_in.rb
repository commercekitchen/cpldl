Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
  if user.present? && user.profile.present? && user.profile.language.present?
    case user.profile.language.name
    when "English"
      I18n.locale = :en
    when "Spanish"
      I18n.locale = :es
    end

    auth.env["rack.session"][:locale] = I18n.locale.to_s
  end
end