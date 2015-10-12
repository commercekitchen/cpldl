require 'rails_helper'

RSpec.describe "courses/show", type: :view do
  before(:each) do
    @course = assign(:course, Course.create!(
      :title => "MyString",
      :seo_page_title => "YourString",
      :meta_desc => "HerString",
      :summary => "HisString",
      :description => "booyah",
      :contributor => "Mr Man",
      :pub_status => "p" 
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyString/)
    expect(rendered).to match(/YourString/)
    expect(rendered).to match(/HerString/)
    expect(rendered).to match(/HisString/)
    expect(rendered).to match(/booyah/)
    expect(rendered).to match(/Mr Man/)
    expect(rendered).to match(/p/)
  end
end
