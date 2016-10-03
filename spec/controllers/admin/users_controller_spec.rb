require "rails_helper"

describe Admin::UsersController do
  before(:each) do
    org = create(:organization, subdomain: "www")
    @request.host = "www.test.host"
    @admin = create(:admin_user, organization: org)
    @user = create(:user, organization: org)
    @user.add_role(:user, org)
    @admin.add_role(:admin, org)
    sign_in @admin
  end

  describe "PATCH #change_user_roles" do
    it "updates the role" do
      patch :change_user_roles, { id: @user.id.to_param, value: "Trainer" }
      expect(@user.current_roles).to eq("trainer")

      patch :change_user_roles, { id: @user.id.to_param, value: "Admin" }
      expect(@user.current_roles).to eq("admin")
    end
  end
end
