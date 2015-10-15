require "rails_helper"

describe ProfilesController do

  describe "#show" do
    context "when logged in" do
      it "should show the user's profile information" do
        user = FactoryGirl.create(:user)
        sign_in user
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    context "when logged out" do
      it "should redirect any action to login page" do
        get :show
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe "#update" do

    context "when logged in" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "allows the user to update their profile information" do
        put :update, id: @user.profile,
        user: { email: @user.email, password: @user.password, password_confirmation: @user.password,
          profile_attributes: { first_name: "Robby", last_name: "Rrown", zip_code: "12345" } },
          authenticity_token: set_authenticity_token

        @user.reload
        expect(@user.profile.first_name).to eq("Robby")
        expect(@user.profile.last_name).to eq("Rrown")
        expect(@user.profile.zip_code).to eq("12345")
      end

      it "allows the user to update just their email" do
        put :update, id: @user.profile,
        user: { email: "new@commercekitchen.com", password: "", password_confirmation: "",
          profile_attributes: { first_name: "", last_name: "", zip_code: "" } },
          authenticity_token: set_authenticity_token
        @user.reload
        expect(response).to redirect_to(profile_path)
        expect(flash[:notice]).to be_present
        expect(@user.unconfirmed_email).to eq("new@commercekitchen.com")
      end

      it "should not allow invalid user information" do
        put :update, id: @user.profile,
        user: { email: @user.email, password: @user.password, password_confirmation: "something else",
          profile_attributes: { first_name: "", last_name: "", zip_code: "" } },
          authenticity_token: set_authenticity_token
        expect(assigns(:user).errors.any?).to be true
      end
    end

    context "when logged out" do
      it "should redirect any action to login page" do
        put :update
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end

  end

end
