require "rails_helper"

describe ProfilesController do

  before(:each) do
    @english = FactoryGirl.create(:language)
    @spanish = FactoryGirl.create(:spanish_lang)
  end

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
          profile: { first_name: "Robby", zip_code: "12345", language_id: FactoryGirl.create(:language) },
          authenticity_token: set_authenticity_token

        @user.reload
        expect(@user.profile.first_name).to eq("Robby")
        expect(@user.profile.zip_code).to eq("12345")
        expect(@user.profile.language.name).to eq("English")
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
