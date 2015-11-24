# == Schema Information
#
# Table name: cms_pages
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  author         :string
#  page_type      :string
#  audience       :string
#  pub_status     :string           default("D")
#  pub_date       :datetime
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string
#  cms_page_order :integer
#

FactoryGirl.define do
  factory :cms_page do
    title "A New Page"
    body "Damn what a body!"
    language_id 1
    author "CK Dev"
    audience "Auth"
    pub_status "D"
    pub_date nil
    seo_page_title "A New Page"
    meta_desc "Meta This and That"
  end
end
