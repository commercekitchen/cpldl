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
