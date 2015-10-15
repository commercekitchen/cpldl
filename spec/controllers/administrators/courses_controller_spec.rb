require "rails_helper"

describe Administrators::CoursesController do
  before(:each) do
    @course1 ||= FactoryGirl.create(:course, title: "Course 1", language: FactoryGirl.create(:language))
    @course2 ||= FactoryGirl.create(:course, title: "Course 2", language: FactoryGirl.create(:language))
    @course3 ||= FactoryGirl.create(:course, title: "Course 3", language: FactoryGirl.create(:language))

    admin_user
  end

  describe "GET #index" do
    it "assigns all courses as @courses" do
      get :index
      expect(assigns(:courses)).to eq([@course1, @course2, @course3])
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
    let(:valid_attributes) { { title:  "Course you can",
                                seo_page_title:  "Doo it | Foo it | Moo it ",
                                meta_desc:  "You're so friggin meta",
                                summary:  "Basically it's basic",
                                description:  "More descriptive that you know!",
                                contributor:  "MeMyself&I <a href='here.com'></a>",
                                pub_status:  "P",
                                language_id: FactoryGirl.create(:language),
                                level: "Advanced" }
                              }

    let(:invalid_attributes) { {  title: "",
                                  seo_page_title: "",
                                  meta_desc: "",
                                  summary: "",
                                  description: "",
                                  contributor: "",
                                  pub_status: "",
                                  language: "",
                                  level: "" }
                                }

    context "with valid params" do
      it "creates a new Course" do
        expect {
          post :create, { course: valid_attributes }
        }.to change(Course, :count).by(1)
      end

      it "assigns a newly created course as @course" do
        post :create, { course: valid_attributes }
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end

      it "redirects to the created course" do
        post :create, { course: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(Course.last)
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
end
