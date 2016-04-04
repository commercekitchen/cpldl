require "rails_helper"

describe Admin::UsersController do
  before(:each) do
    @request.host = "www.test.host"
    @admin = FactoryGirl.create(:admin_user)
    @user = FactoryGirl.create(:user)
    org = FactoryGirl.create(:organization)
    @user.add_role(:user, org)
    @admin.add_role(:admin, org)
    sign_in @admin
  end

  describe "PATCH #change_user_roles" do
    xit "updates the role" do
      patch :change_user_roles, { id: @user.id.to_param, value: "Trainer" }
      expect(@user.current_roles).to eq("trainer")

      patch :change_user_roles, { id: @user.id.to_param, value: "Admin" }
      expect(@user.current_roles).to eq("admin")
    end
  end
end
