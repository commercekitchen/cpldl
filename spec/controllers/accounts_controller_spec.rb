require "rails_helper"

describe AccountsController do

  before(:each) do
    create(:organization, subdomain: "www")
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @request.host = "www.test.host"
  end

  describe "#show" do
    context "when logged in" do
      it "should show the user's account information" do
        user = create(:user)
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
        @user = create(:user)
        sign_in @user
      end

      it "allows the user to update just their email" do
        put :update, id: @user.profile,
          user: { email: "new@commercekitchen.com", password: "", password_confirmation: "" },
          authenticity_token: set_authenticity_token
        @user.reload
        expect(response).to redirect_to(account_path)
        expect(flash[:notice]).to be_present
        expect(@user.unconfirmed_email).to eq("new@commercekitchen.com")
      end

      it "should not allow invalid user information" do
        put :update, id: @user.profile,
          user: { email: @user.email, password: @user.password, password_confirmation: "something else" },
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
