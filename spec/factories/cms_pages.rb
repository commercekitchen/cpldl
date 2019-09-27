# == Schema Information
#
# Table name: cms_pages
#
#  id              :integer          not null, primary key
#  title           :string(90)
#  author          :string
#  audience        :string
#  pub_status      :string           default("D")
#  pub_date        :datetime
#  seo_page_title  :string(90)
#  meta_desc       :string(156)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  slug            :string
#  cms_page_order  :integer
#  language_id     :integer
#  body            :text
#  organization_id :integer
#

FactoryBot.define do
  factory :cms_page do
    organization
    title "A New Page"
    language_id 1
    body "Look at that body!"
    author "CK Dev"
    audience "Auth"
    pub_status "D"
    pub_date nil
    seo_page_title "A New Page"
    meta_desc "Meta This and That"
  end
end
