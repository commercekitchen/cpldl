module RegistrationsHelper
  def branch_options_for(organization)
    branch_options = organization.library_locations.map { |ll| [ll.name, ll.id] }

    if organization.accepts_custom_branches
      branch_options << ["Community Partner", nil]
    end

    options_for_select(branch_options)
  end
end
