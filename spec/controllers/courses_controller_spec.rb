require "rails_helper"

describe CoursesController do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Course 1", language: FactoryGirl.create(:language))
    @course2 = FactoryGirl.create(:course, title: "Course 2", language: FactoryGirl.create(:language))
    @course3 = FactoryGirl.create(:course, title: "Course 3", language: FactoryGirl.create(:language))
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
    it "assigns the requested course (by id) as @course" do
      get :show, id: @course2.to_param
      expect(assigns(:course)).to eq(@course2)
    end

    it "assigns the requested course (by friendly id) as @course" do
      get :show, id: @course2.friendly_id
      expect(assigns(:course)).to eq(@course2)
    end

    it "allows the admin to change the title, and have the old title redirect to the new title" do
      old_url = @course1.friendly_id
      @course1.slug = nil # Must set slug to nil for the friendly url to regenerate
      @course1.title = "New Title"
      @course1.save

      get :show, id: old_url
      expect(assigns(:course)).to eq(@course1)
      expect(response).to have_http_status(:redirect)

      get :show, id: @course1.friendly_id
      expect(assigns(:course)).to eq(@course1)
    end

    it "responds to json" do
      get :show, id: @course1.to_param, format: :json
      expect(response).to have_http_status(:success)
    end
  end

end
