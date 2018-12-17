module RegistrationsHelper
  def branch_options_for(organization, options={})
    branch_options = organization.library_locations.map { |ll| [ll.name, ll.id] }

    if organization.accepts_custom_branches
      profile = options[:profile]
      custom_branch = profile.present? && profile.library_location.present? && profile.library_location.custom?
      branch_options << [profile.library_location_name, profile.library_location_id] if custom_branch
      branch_options << ["Community Partner", nil]
    end

    options_for_select(branch_options, options[:selected])
  end
end
