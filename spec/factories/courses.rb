FactoryGirl.define do
  factory(:course) do
    title "Computer Course"
    seo_page_title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this class you will..."
    description "Description"
    contributor "John Doe"
    pub_status "P"
  end
end
