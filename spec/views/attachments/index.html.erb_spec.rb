require 'rails_helper'

RSpec.describe "attachments/index", type: :view do
  before(:each) do
    assign(:attachments, [
      Attachment.create!(
        :title => "Title"
      ),
      Attachment.create!(
        :title => "Title"
      )
    ])
  end

  it "renders a list of attachments" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
