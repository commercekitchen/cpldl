require 'rails_helper'

RSpec.describe "topics/index", type: :view do
  before(:each) do
    assign(:topics, [
      Topic.create!(
        :title => "Title"
      ),
      Topic.create!(
        :title => "Title"
      )
    ])
  end

  it "renders a list of topics" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
