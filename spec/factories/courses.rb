FactoryGirl.define do
  factory(:course) do
    title "Computer Course"
    seo_page_title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this class you will..."
    description "Description"
    contributor "John Doe"
    level ["Beginner", "Intermediate", "Advanced"].sample  # Todo: I think this should be known, to test against.
    language

    after(:create) do |course|
      create(:lesson, course: course)
    end
  end
end
