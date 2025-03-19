# frozen_string_literal: true

require 'feature_helper'

feature '/heartland route redirects to correct course' do
  let(:org) { create(:organization) }

  it 'redirects for www subdomain' do
    create(:course, organization: org, title: 'Getting Started With Telehealth')
    org.update(subdomain: 'www')
    switch_to_subdomain('www')
    visit '/heartland'
    expect(current_path).to eq('/courses/getting-started-with-telehealth')
  end

  xit 'does not redirect for other subdomains' do
    # This no longer raises an error
    switch_to_subdomain(org.subdomain)
    expect do
      visit '/heartland'
    end.to raise_error ActionController::RoutingError
  end
end