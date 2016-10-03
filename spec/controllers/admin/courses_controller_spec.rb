require "rails_helper"

describe Admin::CoursesController do

  before(:each) do
    @organization = create(:organization)
    @request.host = "chipublib.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @course1 = create(:course, title: "Course1", course_order: 1)
    @course2 = create(:course, title: "Course2", course_order: 2)
    @course3 = create(:course, title: "Course3", course_order: 3)
    @admin = create(:admin_user, organization: @organization)
    @admin.add_role(:admin, @organization)

    @org_course1 = OrganizationCourse.create(organization_id: @organization.id,
                                             course_id: @course1.id)
    @org_course2 = OrganizationCourse.create(organization_id: @organization.id,
                                             course_id: @course2.id)
    @org_course3 = OrganizationCourse.create(organization_id: @organization.id,
                                             course_id: @course3.id)
    sign_in @admin
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index, subdomain: "chipublib"
      expect(assigns(:courses)).to include(@course1, @course2, @course3)
      expect(assigns(:courses).count).to eq(3)
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

  describe "PATCH #update_pub_status" do
    it "updates the status" do
      patch :update_pub_status, { course_id: @course1.id.to_param, value: "P" }
      @course1.reload
      expect(@course1.pub_status).to eq("P")
    end

    it "updates the pub_date if status is published" do
      patch :update_pub_status, { course_id: @course1.id.to_param, value: "A" }
      @course1.reload
      expect(@course1.pub_date).to be(nil)

      patch :update_pub_status, { course_id: @course1.id.to_param, value: "P" }
      @course1.reload
      expect(@course1.pub_date.to_i).to eq(Time.zone.now.to_i)
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
        format: "D",
        other_topic_text: "Learning",
        language_id: create(:language),
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
        format: "",
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
        patch :update, { id: @course1.to_param, course: @course1.attributes, commit: "Save Course and Add Lessons" }
        expect(response).to redirect_to(new_admin_course_lesson_path(@course1, @course1.lessons.first))
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
