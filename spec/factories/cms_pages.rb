# frozen_string_literal: true

FactoryBot.define do
  factory :cms_page do
    sequence(:title) { |n| "Cms Page #{n}" }
    organization
    language
    body 'Look at that body!'
    author 'CK Dev'
    audience 'Auth'
    pub_status 'D'
    pub_date nil
    seo_page_title 'A New Page'
    meta_desc 'Meta This and That'
  end
end
