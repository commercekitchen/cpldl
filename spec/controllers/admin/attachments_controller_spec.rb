require "spec_helper"

describe Admin::AttachmentsController do

  before(:each) do
    @attachment = FactoryGirl.create(:attachment)
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
    @admin = FactoryGirl.create(:admin_user)
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
