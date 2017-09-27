require "rails_helper"

describe ApplicationController do
  describe "#after_signin_path_for" do
    before(:each) do
      @chipublib_organization = create(:organization)
      @npl_organization = create(:organization, subdomain: "npl")
      @www_organization = create(:organization, subdomain: "www")
    end

    it "should only allow sign in for matching subdomain users" do
      @request.host = "www.test.host"
      user = create(:user, organization: @www_organization)
      user.add_role(:user, @www_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(root_path)
    end

    it "should redirect a first time super admin to the profile path" do
      @request.host = "chipublib.test.host"
      user = create(:user, organization: @chipublib_organization)
      Profile.find(user.profile.id).destroy
      user.reload
      user.add_role(:admin, @chipublib_organization)
      user.add_role(:super, @chipublib_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(profile_path)
    end

    it "should redirect a super admin to the admin dashboard path" do
      @request.host = "chipublib.test.host"
      user = create(:user, organization: @chipublib_organization)
      user.add_role(:admin, @chipublib_organization)
      user.add_role(:super, @chipublib_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(admin_dashboard_index_path)
    end

    it "should redirect a regular user to the root_path" do
      @request.host = "chipublib.test.host"
      user = create(:user, organization: @chipublib_organization)
      user.add_role(:user, @chipublib_organization)
      expect(@controller.after_sign_in_path_for(user)).to eq(root_path)
    end

  end

  describe "hide_language_links?" do

    it "should return true if any one of an individual course's routes, i.e. not the index route" do
      allow(@controller).to receive(:params).and_return({ controller: "courses", action: "show" })
      expect(@controller.hide_language_links?).to be true
    end

    it "should return true if any one of an individual course's routes, i.e. not the index route" do
      allow(@controller).to receive(:params).and_return({ controller: "lessons", action: "show" })
      expect(@controller.hide_language_links?).to be true
    end

    it "should return false for the courses index route" do
      allow(@controller).to receive(:params).and_return({ controller: "courses", action: "index" })
      expect(@controller.hide_language_links?).to be false
    end

    it "should return false for the admin/courses route" do
      allow(@controller).to receive(:params).and_return({ controller: "admin/courses", action: "show" })
      expect(@controller.hide_language_links?).to be false
    end

    it "should return false for anything else" do
      allow(@controller).to receive(:params).and_return({ controller: "home", action: "index" })
      expect(@controller.hide_language_links?).to be false
    end

  end

end
