require "rails_helper"

describe Trainer::BaseController do
  describe "#authorize_trainer" do
    before(:each) do
      @request.host = "chipublib.test.host"
      @user = FactoryGirl.create(:user)
      @organization = FactoryGirl.create(:organization)
      @user.add_role(:trainer, @organization)
      sign_in @user
    end
    it "authorizes a trainer" do
      controller.authorize_trainer
      expect(response).to have_http_status(:success)
    end
  end
end