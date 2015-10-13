require "rails_helper"

describe CoursesController do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Course 1")
    @course2 = FactoryGirl.create(:course, title: "Course 2")
    @course3 = FactoryGirl.create(:course, title: "Course 3")
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index
      expect(assigns(:courses)).to eq([@course1, @course2, @course3])
    end

    it "responds to json" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "assigns the requested course as @course" do
      get :show, id: @course2.to_param
      expect(assigns(:course)).to eq(@course2)
    end

    it "responds to json" do
      get :show, id: @course1.to_param, format: :json
      expect(response).to have_http_status(:success)
    end
  end

end
