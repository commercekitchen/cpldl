require "rails_helper"

describe LessonsController do

  before(:each) do
    @course1 = FactoryGirl.create(:course)
    @lesson1 = FactoryGirl.create(:lesson, title: "Lesson1")
    @lesson2 = FactoryGirl.create(:lesson, title: "Lesson2")
    @course1.lessons << [@lesson1, @lesson2]
    @course1.save

    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET #index" do
    it "assigns all lessons for a given course as @lessons" do
      get :index, course_id: @course1.to_param
      expect(assigns(:lessons).count).to eq(2)
      expect(assigns(:lessons).first).to eq(@lesson1)
      expect(assigns(:lessons).second).to eq(@lesson2)
    end

    it "responds to json" do
      get :index, course_id: @course1.to_param, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "assigns the requested lesson as @lesson" do
      get :show, course_id: @course1.to_param, id: 1
      expect(assigns(:lesson)).to eq(@lesson1)
    end

    it "allows the admin to change the title, and have the old title redirect to the new title" do
      old_url = @lesson1.friendly_id
      @lesson1.slug = nil # Must set slug to nil for the friendly url to regenerate
      @lesson1.title = "New Lesson Title"
      @lesson1.save

      get :show, course_id: @course1.to_param, id: old_url
      expect(assigns(:lesson)).to eq(@lesson1)
      expect(response).to have_http_status(:redirect)

      get :show, course_id: @course1.to_param, id: @lesson1.friendly_id
      expect(assigns(:lesson)).to eq(@lesson1)
    end

    it "responds to json" do
      get :show, course_id: @course1.to_param, id: 2, format: :json
      expect(response).to have_http_status(:success)
    end
  end

end
