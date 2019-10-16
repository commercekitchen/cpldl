# frozen_string_literal: true

require 'feature_helper'

feature 'unknown subdomain redirect' do
  before do
    create(:default_organization)
    create(:language)
    create(:spanish_lang)

  end

  scenario 'user visits unknown subdomain' do
    switch_to_subdomain('foobar')
    visit root_path
    expect(current_url).to_not include('foobar')
    expect(current_url).to include('www')
  end

  scenario 'user visits unknown stage subdomain' do
    switch_to_subdomain('foobar.stage')
    visit root_path
    expect(current_url).to_not include('foobar')
    expect(current_url).to include('www.stage.')
  end
end
