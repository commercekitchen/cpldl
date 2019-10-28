# frozen_string_literal: true

RSpec.shared_examples 'User Sidebar Links' do
  scenario 'contains correct links' do
    ['Profile',
     'Login Information',
     'Completed Courses'].each do |link|
      expect(page).to have_link(link)
    end
  end
end

RSpec.shared_examples 'Admin Dashboard Sidebar Links' do
end
