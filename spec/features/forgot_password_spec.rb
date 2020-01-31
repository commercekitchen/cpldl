# frozen_string_literal: true

require 'feature_helper'

feature 'User attempts to request a new password' do
  let!(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }

  before do
    switch_to_subdomain(organization.subdomain)
  end

  it 'should allow user to request a new password' do
    visit '/'
    click_link 'Sign Up / Log In'
    click_link 'Forgot your password?'

    expect(current_path).to eq(new_user_password_path)
    expect(page).to have_content('Forgot your password?')

    fill_in 'Email', with: user.email
    click_button 'Send me reset password instructions'

    expect(page).to have_content('You will receive an email with instructions on how to reset your password in a few minutes.')
  end
end
