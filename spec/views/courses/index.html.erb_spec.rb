require 'rails_helper'

RSpec.describe "courses/index", type: :view do
  before(:each) do
    assign(:courses, [
      Course.create!(
        :title => "MyString",
        :seo_page_title => "YourString",
        :meta_desc => "HerString",
        :summary => "HisString",
        :description => "booyah",
        :contributor => "Mr Man",
        :pub_status => "p" 
      ),
      Course.create!(
        :title => "MyString",
        :seo_page_title => "YourString",
        :meta_desc => "HerString",
        :summary => "HisString",
        :description => "booyah",
        :contributor => "Mr Man",
        :pub_status => "p" 
      )
    ])
  end

  it "renders a list of courses" do
    render
    assert_select "tr>td", :text => "MyString".to_s, :count => 2
    assert_select "tr>td", :text => "YourString".to_s, :count => 2
    assert_select "tr>td", :text => "HerString".to_s, :count => 2
    assert_select "tr>td", :text => "HisString".to_s, :count => 2
    assert_select "tr>td", :text => "booyah".to_s, :count => 2
    assert_select "tr>td", :text => "Mr Man".to_s, :count => 2
    assert_select "tr>td", :text => "p".to_s, :count => 2
  end
end
