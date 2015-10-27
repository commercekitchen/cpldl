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

  describe "GET #your" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "allows the user to view their courses" do
        get :your
        expect(assigns(:courses)).to eq([])
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        get :your
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe "GET #completed" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "allows the user to view their completed courses" do
        get :completed
        expect(assigns(:courses)).to eq([])
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        get :completed
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe "POST #start" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @lesson2 = FactoryGirl.create(:lesson)
        @lesson3 = FactoryGirl.create(:lesson)
        @course1.lessons << [@lesson2, @lesson3]
        sign_in @user
      end

      it "records that a user started a course" do
        post :start, { course_id: @course1 }
        progress = @user.course_progresses.last
        expect(progress.course_id).to eq(@course1.id)
        expect(response).to redirect_to(course_lesson_path(@course1, 1))
      end

      it "sends a user to the correct lesson if the course was already started" do
        @user.course_progresses.create({ user_id: @user.id, course_id: @course1.id, lessons_completed: 2 })
        post :start, { course_id: @course1 }
        expect(response).to redirect_to(course_lesson_path(@course1, 3))
      end

      it "only creates one course progress record per user per course" do
        expect(@user.course_progresses.count).to eq(0)
        post :start, { course_id: @course1 }
        expect(@user.course_progresses.count).to eq(1)
        post :start, { course_id: @course1 }
        expect(@user.course_progresses.count).to eq(1)
        post :start, { course_id: @course2 }
        expect(@user.course_progresses.count).to eq(2)
        post :start, { course_id: @course2 }
        expect(@user.course_progresses.count).to eq(2)
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        post :start, { course_id: @course1 }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

end
