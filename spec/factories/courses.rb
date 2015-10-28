FactoryGirl.define do
  factory(:course) do
    title "Computer Course"
    meta_desc "A first course in computing"
    summary "In this course you will..."
    description "Description"
    contributor "John Doe"
    level "Beginner"
    language
  end
end
