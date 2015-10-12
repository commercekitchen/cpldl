require 'rails_helper'

RSpec.describe "languages/index", type: :view do
  before(:each) do
    assign(:languages, [
      Language.create!(
        :name => "Name"
      ),
      Language.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of languages" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
