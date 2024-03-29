# frozen_string_literal: true

require 'feature_helper'

feature 'subdomain redirect' do
  before do
    create(:default_organization)
  end

  scenario 'user visits unknown subdomain' do
    switch_to_subdomain('foobar')
    visit root_path
    expect(current_url).to_not include('foobar')
    expect(current_url).to include('www')
  end

  scenario 'user visits chicago subdomain' do
    create(:organization, subdomain: 'chipublib')
    switch_to_subdomain('chicago')
    visit root_path
    expect(current_url).to_not include('chicago')
    expect(current_url).to include('chipublib')
  end

  scenario 'user visits unknown stage subdomain' do
    ActionDispatch::Http::URL.tld_length = 2
    switch_to_subdomain('foobar', 'stage.lvh.me')
    visit root_path
    expect(current_url).to_not include('foobar')
    expect(current_url).to include('www.stage.')
    ActionDispatch::Http::URL.tld_length = 1
  end

  scenario 'user visits with no subdomain' do
    visit root_path
    expect(current_url).to include('www.')
  end

  scenario 'user visits staging with no subdomain' do
    ActionDispatch::Http::URL.tld_length = 2
    switch_to_subdomain('', 'stage.lvh.me')
    visit(root_path)
    expect(current_url).to include('www.stage.')
    ActionDispatch::Http::URL.tld_length = 1
  end
end
