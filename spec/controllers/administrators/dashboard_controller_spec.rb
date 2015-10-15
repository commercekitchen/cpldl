require "rails_helper"

describe Administrators::DashboardController do
  context "get #index" do
    it "allow admin access" do
      adminu ||= FactoryGirl.create(:admin_user)
      adminu.add_role(:admin)
      sign_in(adminu)

      get :index
      expect(response).to have_http_status(:success)
      sign_out(adminu)
    end

    it "allow super access" do
      superu ||= FactoryGirl.create(:super_user)
      superu.add_role(:super)
      sign_in(superu)

      get :index
      expect(response).to have_http_status(:success)
      sign_out(superu)
    end

    it "refuse access" do
      user ||= FactoryGirl.create(:user)

      sign_in(user)
      get :index
      expect(response).to have_http_status(:redirect)
    end

    it "assigns all courses as @courses" do
      admin_user
      course1 ||= FactoryGirl.create(:course, title: "Course 1", language: FactoryGirl.create(:language))
      course2 ||= FactoryGirl.create(:course, title: "Course 2", language: FactoryGirl.create(:language))
      course3 ||= FactoryGirl.create(:course, title: "Course 3", language: FactoryGirl.create(:language))

      get :index
      expect(assigns(:courses)).to eq([course1, course2, course3])
    end
  end
end
