require 'rails_helper'

RSpec.describe AdministratorsController, type: :controller do

  # => this should be removed from here and moved to application controller spec, but I am not sure how to do this
  describe "#authorize" do
    it "allows access" do
      adminu ||= FactoryGirl.create(:admin_user)
      superu ||= FactoryGirl.create(:super_user)
      adminu.add_role(:admin)
      superu.add_role(:super)

      sign_in(adminu)
      get :index
      expect(response).to have_http_status(:success)

      sign_out(adminu)
      sign_in(superu)
      get :index
      expect(response).to have_http_status(:success)
    end

    it "refuses access" do
      user ||= FactoryGirl.create(:user)

      sign_in(user)
      get :index
      expect(response).to have_http_status(:redirect)
    end
  end
end
