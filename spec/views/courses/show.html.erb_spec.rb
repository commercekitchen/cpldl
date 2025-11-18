# frozen_string_literal: true

require 'rails_helper'

describe 'courses/show.html.erb' do
  let(:org) { create(:default_organization) }
  let(:course) { create(:course_with_lessons, organization: org, meta_desc: 'Meta description.', seo_page_title: 'SEO Title') }
  let!(:admin) { create(:user, :admin, organization: org) }
  let!(:user) { create(:user, organization: org) }
  let!(:course_progress) { create(:course_progress, course: course, user: user) }

  before(:each) do
    allow(view).to receive(:current_organization).and_return(org)
    allow(view).to receive(:subdomain?).and_return(false)
    allow(view).to receive(:hide_language_links?).and_return(false)
    allow(view).to receive(:top_level_domain?).and_return(true)
    view.extend Pundit::Authorization # make `policy` available
    assign(:course, course)
  end

  context 'when logged in as an admin' do
    it 'displays the edit course button' do
      sign_in admin
      allow(view).to receive(:pundit_user).and_return(admin)
      render
      expect(rendered).to have_link 'Edit Course', href: edit_admin_course_path(course)
    end
  end

  context 'when logged in as a normal user' do
    it 'does not display the edit course button' do
      sign_in user
      allow(view).to receive(:pundit_user).and_return(user)
      render
      expect(rendered).not_to have_content 'Edit Course'
    end

    it "shows the 'Add to your plan' link if the course is not currently tracked" do
      sign_in user
      allow(view).to receive(:pundit_user).and_return(user)
      course_progress.update!(tracked: true)
      render
      expect(rendered).to_not have_link 'Add to your plan'
      expect(rendered).to have_link 'Remove from your plan'
    end

    it "shows the 'Remove from your plan' link if the course is not currently tracked" do
      sign_in user
      allow(view).to receive(:pundit_user).and_return(user)
      course_progress.update(tracked: false)
      render
      expect(rendered).to have_link 'Add to your plan'
      expect(rendered).to_not have_link 'Remove from your plan'
    end

    it 'displays activity instructions on page' do
      sign_in user
      allow(view).to receive(:pundit_user).and_return(user)
      render
      expect(rendered).to have_content 'Click on a lesson below to begin'
    end
  end

  context 'as logged out user (and search engine)' do
    it 'uses the meta_desc field as a meta description tag' do
      render template: 'courses/show', layout: 'layouts/application'
      expect(rendered).to have_selector("meta[name='description'][content='Meta description.']", visible: false)
    end

    it 'uses the course summary field as the meta description tag if the seo_page_title is blank' do
      course.meta_desc = ''
      render template: 'courses/show', layout: 'layouts/application'
      expect(rendered).to have_selector("meta[name='description'][content='In this course you will...']", visible: false)
    end

    it 'uses the seo title if available' do
      render template: 'courses/show', layout: 'layouts/application'
      expect(rendered).to have_selector('title', text: 'SEO Title', visible: false)
    end

    it 'uses the course title if seo title is not available' do
      course.seo_page_title = ''
      render template: 'courses/show', layout: 'layouts/application'
      expect(rendered).to have_selector('title', text: course.title, visible: false)
    end

    it 'respects html formatting of the body' do
      course.description = '<strong>Should display in bold</strong>'
      render
      expect(rendered).to have_selector('strong', text: 'Should display in bold')
    end

    it "does not show the 'Add to your plan' or 'Remove from your plan' link" do
      render
      expect(rendered).to_not have_link 'Add to your plan'
      expect(rendered).to_not have_link 'Remove from your plan'
    end
  end
end
