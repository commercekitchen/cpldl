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

  describe "#export_user_info" do
    before do
      4.times do
        create(:user, organization: @user.organization)
      end

      get :export_user_info, format: :csv
    end

    it "assigns correct number of users" do
      expect(assigns(:users).count).to eq(6)
    end
  end
end
