require "rails_helper"

describe LessonsController do

  before(:each) do
    @course1 = FactoryGirl.create(:course)
    @lesson1 = FactoryGirl.create(:lesson, title: "Lesson1", lesson_order: 1)
    @lesson2 = FactoryGirl.create(:lesson, title: "Lesson2", lesson_order: 2)
    @lesson3 = FactoryGirl.create(:lesson, title: "Lesson3", lesson_order: 3)
    @course1.lessons << [@lesson1, @lesson2, @lesson3]
    @course1.save

    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET #index" do
    it "assigns all lessons for a given course as @lessons" do
      get :index, course_id: @course1.to_param
      expect(assigns(:lessons).count).to eq(3)
      expect(assigns(:lessons).first).to eq(@lesson1)
      expect(assigns(:lessons).second).to eq(@lesson2)
      expect(assigns(:lessons).third).to eq(@lesson3)
    end

    it "responds to json" do
      get :index, course_id: @course1.to_param, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "assigns the requested lesson as @lesson" do
      get :show, course_id: @course1.to_param, id: @lesson1.id
      expect(assigns(:lesson)).to eq(@lesson1)
    end

    it "assigns the next lesson as @next_lesson" do
      get :show, course_id: @course1.to_param, id: @lesson1.id
      expect(assigns(:next_lesson)).to eq(@lesson2)
    end

    it "creates a course_progress model, if not previously created" do
      expect(@user.course_progresses.count).to eq(0)
      get :show, course_id: @course1.to_param, id: @lesson1.id
      expect(@user.course_progresses.count).to eq(1)
    end

    it "only creates the course_progress once" do
      get :show, course_id: @course1.to_param, id: @lesson1.id
      get :show, course_id: @course1.to_param, id: @lesson1.id
      expect(@user.course_progresses.count).to eq(1)
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
      get :show, course_id: @course1.to_param, id: @lesson2.id, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #complete" do
    it "marks a lesson for a given user as complete" do
      post :complete, course_id: @course1.to_param, lesson_id: @lesson2.to_param
      progress = @user.course_progresses.find_by_course_id(@course1.id)
      expect(progress.completed_lessons.count).to eq(1)
      expect(response).to redirect_to(course_lesson_path(@course1.to_param, @lesson3.id))
    end

    it "marks a course as complete if the assessment was completed" do
      @lesson3.is_assessment = true
      @lesson3.save
      post :complete, course_id: @course1.to_param, lesson_id: @lesson3.to_param
      progress = @user.course_progresses.find_by_course_id(@course1.id)
      expect(progress.complete?).to be true
    end

    it "renders the course completion view if the assessment was completed" do
      @lesson3.is_assessment = true
      @lesson3.save
      post :complete, course_id: @course1.to_param, lesson_id: @lesson3.to_param
      expect(response).to redirect_to(course_complete_path(@course1.to_param))
    end

    it "responds to json" do
      post :complete, course_id: @course1.to_param, lesson_id: @lesson2.to_param, format: :json
      expect(response).to have_http_status(:success)
      json = JSON(response.body)
      expect(json["next_lesson"]).to eq(course_lesson_path(@course1.to_param, @lesson3.id))
    end
  end

end
