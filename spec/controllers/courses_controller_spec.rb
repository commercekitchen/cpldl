require "rails_helper"

describe CoursesController do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Course 1",
                                           language: FactoryGirl.create(:language))
    @course2 = FactoryGirl.create(:course, title: "Course 2",
                                           language: FactoryGirl.create(:language))
    @course3 = FactoryGirl.create(:course, title: "Course 3",
                                           language: FactoryGirl.create(:language),
                                           description: "Ruby on Rails")
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index
      expect(assigns(:courses)).to eq([@course1, @course2, @course3])
    end

    it "assigns all courses as @courses with an empty params" do
      get :index, {}
      expect(assigns(:courses)).to eq([@course1, @course2, @course3])
    end

    it "assigns search results to @results" do
      get :index, { search: "ruby" }
      expect(assigns(:results)).to eq([@course3])
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
        @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true)
        @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: false)
        @user.course_progresses << [@course_progress1, @course_progress2]
      end

      it "allows the user to view their tracked courses" do
        get :your
        expect(assigns(:courses)).to eq([@course1])
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
        @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id,
                                                                 tracked: true,
                                                                 completed_at: Time.zone.now)
        @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id,
                                                                 tracked: true)
        @course_progress3 = FactoryGirl.create(:course_progress, course_id: @course3.id,
                                                                 tracked: true,
                                                                 completed_at: Time.zone.now)
        @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3]
        sign_in @user
      end

      it "allows the user to view their completed courses" do
        get :completed
        expect(assigns(:courses)).to include(@course1, @course3)
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

  describe "GET #complete" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "allows the user to view the complete view" do
        get :complete, { course_id: @course1 }
        expect(assigns(:course)).to eq(@course1)
      end

      it "generates a PDF when send as format pdf" do
        get :complete, { course_id: @course1, format: 'pdf'}
        expect(assigns(:pdf)).not_to be_empty
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        get :complete, { course_id: @course1 }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe "POST #start" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @lesson1 = FactoryGirl.create(:lesson, lesson_order: 1)
        @lesson2 = FactoryGirl.create(:lesson, lesson_order: 2)
        @lesson3 = FactoryGirl.create(:lesson, lesson_order: 3)
        @lesson4 = FactoryGirl.create(:lesson)
        @course1.lessons << [@lesson1, @lesson2, @lesson3]
        @course2.lessons << [@lesson4]
        sign_in @user
      end

      it "records that a user started a course" do
        post :start, { course_id: @course1 }
        progress = @user.course_progresses.last
        expect(progress.course_id).to eq(@course1.id)
        expect(progress.tracked).to be true
        expect(response).to redirect_to(course_lesson_path(@course1, @course1.lessons.where(lesson_order: 1).first.id))
      end

      it "sends a user to the correct lesson if the course was already started" do
        @user.course_progresses.create({ user_id: @user.id, course_id: @course1.id })
        @user.course_progresses.first.completed_lessons.create({ lesson_id: @lesson1.id })
        @user.course_progresses.first.completed_lessons.create({ lesson_id: @lesson2.id })
        post :start, { course_id: @course1 }
        expect(response).to redirect_to(course_lesson_path(@course1, @lesson3.id))
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

  describe "POST #add" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "marks a course as tracked" do
      post :add, { course_id: @course1 }
      progress = @user.course_progresses.find_by_course_id(@course1.id)
      expect(progress.tracked).to be true
    end
  end

  describe "POST #remove" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "marks a course as un-tracked" do
      progress = @user.course_progresses.where(course_id: @course1.id).first_or_create
      progress.tracked = false
      progress.save

      post :remove, { course_id: @course1 }
      progress = @user.course_progresses.find_by_course_id(@course1.id)
      expect(progress.tracked).to be false
    end
  end

  describe "GET #view_attachment" do
    context "when logged in" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @attachment = FactoryGirl.create(:attachment)
        sign_in @user
      end

      it "allows the user to view an uploaded file" do
        file = fixture_file_upload(Rails.root.join("spec", "fixtures", "testfile.pdf"), "application/pdf")
        @course1.attachments.create(document: file, doc_type: "post-course")
        get :view_attachment, { course_id: @course1, attachment_id: @course1.attachments.first.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        get :view_attachment, { course_id: @course1, attachment_id: 1 }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

end
