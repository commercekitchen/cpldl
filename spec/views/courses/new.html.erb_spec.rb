require 'rails_helper'

RSpec.describe "courses/new", type: :view do
  before(:each) do
    assign(:course, Course.new(
      :title => "MyString",
      :seo_page_title => "YourString",
      :meta_desc => "HerString",
      :summary => "HisString",
      :description => "booyah",
      :contributor => "Mr Man",
      :pub_status => "p" 
    ))
  end

  it "renders new course form" do
    render

    assert_select "form[action=?][method=?]", courses_path, "post" do

      assert_select "input#course_title[name=?]", "course[title]"

      assert_select "input#course_seo_page_title[name=?]", "course[seo_page_title]"

      assert_select "input#course_meta_desc[name=?]", "course[meta_desc]"

      assert_select "input#course_summary[name=?]", "course[summary]"

      assert_select "input#course_description[name=?]", "course[description]"

      assert_select "input#course_contributor[name=?]", "course[contributor]"

      assert_select "input#course_pub_status[name=?]", "course[pub_status]"

    end
  end
end
