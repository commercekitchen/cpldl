# == Schema Information
#
# Table name: courses
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  summary        :string(156)
#  description    :text
#  contributor    :string
#  pub_status     :string           default("D")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :integer
#  level          :string
#  notes          :text
#  slug           :string
#  course_order   :integer
#  pub_date       :datetime
#  format         :string
#  subsite_course :boolean          default(FALSE)
#  parent_id      :integer
#  display_on_dl  :boolean          default(FALSE)
#

require "rails_helper"

describe CoursesController do

  before(:each) do
    request.host = "chipublib.example.com"
    @language = create(:language)
    @spanish = create(:spanish_lang)
    @organization = create(:organization)
    @category1 = create(:category, organization: @organization)
    @category2 = create(:category, :disabled, organization: @organization)

    @course1 = create(:course, title: "Course 1",
                               language: @language,
                               description: "Mocha Java Scripta",
                               organization: @organization,
                               category: @category1)
    @course2 = create(:course, title: "Course 2",
                               language: @language,
                               organization: @organization)
    @course3 = create(:course, title: "Course 3",
                               language: @language,
                               description: "Ruby on Rails",
                               organization: @organization)
    @disabled_category_course = create(:course, title: "Disabled Category Course",
                                                language: @language,
                                                description: "Foo Bar Baz",
                                                organization: @organization,
                                                category: @category2)
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index
      expect(assigns(:courses)).to include(@course1, @course2, @course3, @disabled_category_course)
    end

    it "assigns all courses as @courses with an empty params" do
      get :index, {}
      expect(assigns(:courses)).to include(@course1, @course2, @course3, @disabled_category_course)
    end

    it "assigns search results to @courses" do
      get :index, { search: "ruby" }
      expect(assigns(:courses)).to eq([@course3])
    end

    it "responds to json" do
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end

    it "assigns categories" do
      get :index
      expect(assigns(:category_ids)).to eq([@category1.id])
    end

    it "assigns uncategorized courses" do
      get :index
      expect(assigns(:uncategorized_courses)).to include(@course2, @course3, @disabled_category_course)
    end

    it "has correct number of uncategorized courses" do
      get :index
      expect(assigns(:uncategorized_courses).count).to eq(3)
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
      # @course1.slug = nil # Must set slug to nil for the friendly url to regenerate
      @course1.title = "New Title"
      @course1.save

      get :show, id: old_url
      expect(assigns(:course)).to eq(@course1)
      expect(response).to have_http_status(:success)

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
        @user = create(:user, organization: @organization)
        sign_in @user
        @course_progress1 = create(:course_progress, course_id: @course1.id, tracked: true)
        @course_progress2 = create(:course_progress, course_id: @course2.id, tracked: false)
        @course_progress3 = create(:course_progress, course_id: @course3.id, tracked: true)
        @course_progress4 = create(:course_progress, course_id: @disabled_category_course.id, tracked: true)
        @user.course_progresses << [@course_progress1, @course_progress2, @course_progress3, @course_progress4]
      end

      it "allows the user to view their tracked courses" do
        get :your
        expect(assigns(:courses)).to include(@course1, @course3, @disabled_category_course)
      end

      it "assigns @results if search params exist" do
        get :your, { search: "java" }
        expect(assigns(:results)).to eq([@course1])
      end

      it "assigns search results to @courses" do
        get :your, { search: "java" }
        expect(assigns(:courses)).to eq([@course1])
      end

      it "assigns categories" do
        get :your
        expect(assigns(:category_ids)).to eq([@category1.id])
      end

      it "assigns uncategorized courses including courses with a disabled category" do
        get :your
        expect(assigns(:uncategorized_courses)).to include(@course3, @disabled_category_course)
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
        @user = create(:user, organization: @organization)
        @course_progress1 = create(:course_progress, course_id: @course1.id,
                                                     tracked: true,
                                                     completed_at: Time.zone.now)
        @course_progress2 = create(:course_progress, course_id: @course2.id,
                                                     tracked: true)
        @course_progress3 = create(:course_progress, course_id: @course3.id,
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
        @user = create(:user, organization: @organization)
        sign_in @user
      end

      it "allows the user to view the complete view" do
        get :complete, { course_id: @course1 }
        expect(assigns(:course)).to eq(@course1)
      end

      it "generates a PDF when send as format pdf" do
        # the send on this opens a term window on run
        get :complete, { course_id: @course1, format: "pdf" }
        expect(assigns(:pdf)).not_to be_empty
      end
    end

    context "when logged out" do
      it "should allow completion" do
        get :complete, { course_id: @course1 }
        expect(response).to have_http_status(:success)
        expect(assigns(:course)).to eq(@course1)
      end
    end
  end

  describe "POST #start" do
    context "when logged in" do
      before(:each) do
        @user = create(:user)
        @lesson1 = create(:lesson, lesson_order: 1)
        @lesson2 = create(:lesson, lesson_order: 2)
        @lesson3 = create(:lesson, lesson_order: 3)
        @lesson4 = create(:lesson)
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
        @lesson1 = create(:lesson, lesson_order: 1)
        @lesson2 = create(:lesson, lesson_order: 2)
        @lesson3 = create(:lesson, lesson_order: 3)
        @lesson4 = create(:lesson)
        @course1.lessons << [@lesson1, @lesson2, @lesson3]
        @course2.lessons << [@lesson4]

        post :start, { course_id: @course1 }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(course_lesson_path(@course1, @lesson1.id))
      end
    end
  end

  describe "POST #add" do
    before(:each) do
      @user = create(:user)
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
      @user = create(:user)
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
        @user = create(:user)
        @attachment = create(:attachment)
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
      it "should all view" do
        file = fixture_file_upload(Rails.root.join("spec", "fixtures", "testfile.pdf"), "application/pdf")
        @course1.attachments.create(document: file, doc_type: "post-course")
        get :view_attachment, { course_id: @course1, attachment_id: @course1.attachments.first.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #quiz" do
    context "when logged in" do
      before(:each) do
        @user = create(:user)
        sign_in @user
      end

      it "should have a valid route and template" do
        get :quiz
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:quiz)
      end
    end
  end

  describe "POST #quiz_submit" do
    context "when logged in" do

      let(:choices) {
        { "set_one" => "2", "set_two" => "2", "set_three" => "3" }
      }

      before(:each) do
        @user = create(:user, organization: @organization)
        @core_topic = create(:topic, title: "Core")
        @topic = create(:topic, title: "Government")

        @desktop_course = create(:course, language: @language, format: "D", level: "Intermediate", topics: [@core_topic])
        @mobile_course = create(:course, language: @language, format: "M", level: "Intermediate", topics: [@core_topic])
        @topic_course = create(:course, language: @language, topics: [@topic])

        [@desktop_course, @mobile_course, @topic_course].each do |course|
          create(:organization_course, organization_id: @organization.id, course_id: course.id)
        end

        sign_in @user
      end

      it "should add correct number of course progresses to user" do
        expect do
          post :quiz_submit, choices
        end.to change(CourseProgress, :count).by(3)
      end

      it "should add correct course progresses to user" do
        post :quiz_submit, choices
        @user.reload
        expect(@user.course_progresses.map(&:course_id)).to include(@desktop_course.id, @mobile_course.id, @topic_course.id)
      end

      it "should store quiz responses for user" do
        post :quiz_submit, choices
        @user.reload
        expect(@user.quiz_responses_object).to eq(choices)
      end

      it "should not overwrite quiz responses for user" do
        post :quiz_submit, choices
        post :quiz_submit, { "set_one" => "3", "set_two" => "3", "set_three" => "5" }
        @user.reload
        expect(@user.quiz_responses_object).to eq(choices)
      end
    end
  end

end
