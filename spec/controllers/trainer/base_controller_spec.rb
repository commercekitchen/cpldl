require "rails_helper"

describe Trainer::BaseController do
  describe "#authorize_trainer" do
    before(:each) do
      @organization = create(:organization)
      @request.host = "chipublib.test.host"
      @user = create(:user, organization: @organization)
      @user.add_role(:trainer, @organization)
      sign_in @user
    end
    it "authorizes a trainer" do
      controller.authorize_trainer
      expect(response).to have_http_status(:success)
    end
  end
end
