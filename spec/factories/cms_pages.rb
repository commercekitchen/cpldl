FactoryGirl.define do
  factory :cms_page do
    title "A New Page"
    page_type "O"
    author "CK Dev"
    audience "Auth"
    pub_status "D"
    pub_date nil
    seo_page_title "A New Page"
    meta_desc "Meta This and That"
  end
end
