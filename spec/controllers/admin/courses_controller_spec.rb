require "rails_helper"

describe Admin::CoursesController do

  before(:each) do
    @course1 = FactoryGirl.create(:course, title: "Course1", language: FactoryGirl.create(:language))
    @course2 = FactoryGirl.create(:course, title: "Course2", language: FactoryGirl.create(:language))
    @course3 = FactoryGirl.create(:course, title: "Course3", language: FactoryGirl.create(:language))

    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index
      expect(assigns(:courses)).to eq([@course1, @course2, @course3])
    end
  end

  describe "GET #show" do
    it "assigns the requested course as @course" do
      get :show, id: @course1.to_param
      expect(assigns(:course)).to eq(@course1)
    end
  end

  describe "GET #new" do
    it "assigns a new course as @course" do
      get :new
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe "GET #edit" do
    it "assigns the requested course as @course" do
      get :edit, { id: @course1.to_param }
      expect(assigns(:course)).to eq(@course1)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      { title:  "Course you can",
        seo_page_title:  "Doo it | Foo it | Moo it ",
        meta_desc:  "You're so friggin meta",
        summary:  "Basically it's basic",
        description:  "More descriptive that you know!",
        contributor:  "MeMyself&I <a href='here.com'></a>",
        pub_status:  "P",
        other_topic_text: "Learning",
        language_id: FactoryGirl.create(:language),
        level: "Advanced",
        course_order: "" }
    end

    let(:invalid_attributes) do
      { title: "",
        seo_page_title: "",
        meta_desc: "",
        summary: "",
        description: "",
        contributor: "",
        pub_status: "",
        language: "",
        level: "",
        other_topic_text: "",
        course_order: "" }
    end

    context "with valid params" do
      it "creates a new Course" do
        expect do
          post :create, { course: valid_attributes }
        end.to change(Course, :count).by(1)
      end

      it "assigns a newly created course as @course" do
        post :create, { course: valid_attributes }
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end

      it "creates a new topic, if given" do
        valid_attributes[:other_topic] = "1"
        valid_attributes[:other_topic_text] = "Some other topic"
        post :create, { course: valid_attributes }
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
        expect(assigns(:course).topics.last.title).to include("Some other topic")
      end

      it "redirects to the admin edit view of the course" do
        post :create, { course: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_admin_course_lesson_path(Course.find_by_title(valid_attributes[:title])))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved course as @course" do
        post :create, { course: invalid_attributes }
        expect(assigns(:course)).to be_a_new(Course)
      end

      it "re-renders the 'new' template" do
        post :create, { course: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST #update" do
    context "with valid params" do
      it "updates an existing Course" do
        patch :update, { id: @course1.to_param, course: @course1.attributes, commit: "Save Course" }
        expect(response).to redirect_to(edit_admin_course_path(@course1))
      end

      it "updates an existing Course, and moves on to lessons" do
        patch :update, { id: @course1.to_param, course: @course1.attributes, commit: "Save Course and Edit Lessons" }
        expect(response).to redirect_to(new_admin_course_lesson_path(@course1))
      end

      it "creates a new topic, if given" do
        valid_attributes = @course1.attributes
        valid_attributes[:other_topic] = "1"
        valid_attributes[:other_topic_text] = "Another new topic"
        patch :update, { id: @course1.to_param, course: valid_attributes }
        expect(assigns(:course).topics.last.title).to include("Another new topic")
      end
    end
  end
end
