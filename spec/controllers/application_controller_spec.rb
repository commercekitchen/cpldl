require "rails_helper"

describe ApplicationController do

  describe "#after_signin_path_for" do
    before(:each) do
      @chipublib_organization = create(:organization)
      @www_organization = create(:organization, subdomain: "www")
    end

    it "should only allow sign in for matching subdomain users" do
      @request.host = "www.test.host"
      user = FactoryGirl.create(:user)
      user.add_role(:user, @www_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(root_path)
    end

    it "should redirect a first time super admin to the profile path" do
      @request.host = "chipublib.test.host"
      user = FactoryGirl.create(:user)
      user.add_role(:admin, @chipublib_organization)
      user.add_role(:super, @chipublib_organization)
      user.sign_in_count = 1
      expect(@controller.after_sign_in_path_for(user)).to eq(profile_path)
    end

    it "should redirect a super admin to the admin dashboard path" do
      @request.host = "chipublib.test.host"
      user = FactoryGirl.create(:user)
      user.add_role(:admin, @chipublib_organization)
      user.add_role(:super, @chipublib_organization)
      user.sign_in_count = 2
      expect(@controller.after_sign_in_path_for(user)).to eq(admin_dashboard_index_path)
    end

    it "should redirect a regular user to the root_path" do
      @request.host = "chipublib.test.host"
      user = FactoryGirl.create(:user)
      user.add_role(:user, @chipublib_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(root_path)
    end
  end

end
