require "rails_helper"

RSpec.describe ProfilesController, type: :controller do
  
  describe "GET #show" do
    before(:each) do
      set_devise_env
      @user = FactoryGirl.create(:user)
      sign_in(@user)
    end

    context "when logged in" do
      it ".show" do 
        get :show
        expect(response).to have_http_status(:success)
      end

      # => I have no idea, I don't get why this wont pass, it complains about hash
      it ".update" do
        put :update, id: @user.profile, :user => { :email => @user.email, 
                                                   :password => @user.password, 
                                                   :password_confirmation => @user.password, 
                          :profile_attributes => { :first_name => "Robby", 
                                                   :last_name => @user.profile.last_name, 
                                                   :zip_code => @user.profile.zip_code } }, authenticity_token: set_authenticity_token

        @user.reload.profile.first_name.should == "Robby"
      end
    end

    context "when logged out" do
      it "redirects" do
        sign_out(@user)
        get :show
        expect(response).to have_http_status(:redirect)
      end
    end  
  end
end