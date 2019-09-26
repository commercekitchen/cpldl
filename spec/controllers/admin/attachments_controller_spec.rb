require "rails_helper"

describe Admin::AttachmentsController do

  before(:each) do
    @organization = create(:default_organization)
    @request.host = "www.test.host"
    @attachment = create(:attachment)
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @admin = create(:user)
    @admin.add_role(:admin)
    sign_in @admin

    @request.env["HTTP_REFERER"] = "http://test.com/admin/courses/new"
  end

  describe "DELETE #destroy" do
    context "success" do
      it "deletes and attachment" do
        expect { delete :destroy, id: @attachment.to_param }.to change(Attachment, :count).by(-1)
      end
    end
  end
end
