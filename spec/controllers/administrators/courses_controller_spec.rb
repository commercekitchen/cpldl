require 'rails_helper'

describe Administrators::CoursesController do
  language ||= FactoryGirl.create(:language)
  # This should return the minimal set of attributes required to create a valid
  # Course. As you add validations to Course, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {  { title:  "Course you can", 
                              seo_page_title:  "Doo it | Foo it | Moo it ", 
                              meta_desc:  "You're so friggin meta", 
                              summary:  "Basically it's basic", 
                              description:  "More descriptive that you know!", 
                              contributor:  "MeMyself&I <a href='here.com'></a>", 
                              pub_status:  "p",
                              language: language,
                              level: "Advanced" } }

  let(:invalid_attributes) { {  title: "", 
                                seo_page_title: "", 
                                meta_desc: "", 
                                summary: "", 
                                description: "", 
                                contributor: "", 
                                pub_status: "",
                                language: "",
                                level: "" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CoursesController. Be sure to keep this updated too.
  before(:each) do
    user ||= FactoryGirl.create(:admin_user)
    sign_in(user)
  end

  let(:valid_session) { { } }

  describe "GET #index" do
    it "assigns all courses as @courses" do
      course = Course.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:courses)).to eq([course])
    end
  end

  describe "GET #show" do
    it "assigns the requested course as @course" do
      course = Course.create! valid_attributes
      get :show, {:id => course.to_param}, valid_session
      expect(assigns(:course)).to eq(course)
    end
  end

  describe "GET #new" do
    it "assigns a new course as @course" do
      get :new, {}, valid_session
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe "GET #edit" do
    it "assigns the requested course as @course" do
      course = Course.create! valid_attributes
      get :edit, {:id => course.to_param}, valid_session
      expect(assigns(:course)).to eq(course)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Course" do
        expect {
          post :create, {:course => valid_attributes}, valid_session
        }.to change(Course, :count).by(1)
      end

      it "assigns a newly created course as @course" do
        post :create, {:course => valid_attributes}, valid_session
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end

      it "redirects to the created course" do
        post :create, {:course => valid_attributes}, valid_session
        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved course as @course" do
        post :create, {:course => invalid_attributes}, valid_session
        expect(assigns(:course)).to be_a_new(Course)
      end

      it "re-renders the 'new' template" do
        post :create, {:course => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { {  title:  "What you need", 
                                seo_page_title:  "More-we-learn", 
                                meta_desc:  "Hows that Meta-tate?", 
                                summary:  "Sum sum summary", 
                                description:  "Thing thing thing", 
                                contributor:  "MeMyself&I <a href='there.com'></a>", 
                                pub_status:  "d", 
                                language: language,
                                level: "Beginner" }
      }

      it "updates the requested course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => new_attributes}, valid_session
        course.reload
        expect(response).to have_http_status(:redirect)
      end

      it "assigns the requested course as @course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => valid_attributes}, valid_session
        expect(assigns(:course)).to eq(course)
      end

      it "redirects to the course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => valid_attributes}, valid_session
        expect(response).to redirect_to(course)
      end
    end

    context "with invalid params" do
      it "assigns the course as @course" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => invalid_attributes}, valid_session
        expect(assigns(:course)).to eq(course)
      end

      it "re-renders the 'edit' template" do
        course = Course.create! valid_attributes
        put :update, {:id => course.to_param, :course => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested course" do
      course = Course.create! valid_attributes
      expect {
        delete :destroy, {:id => course.to_param}, valid_session
      }.to change(Course, :count).by(-1)
    end

    it "redirects to the courses list" do
      course = Course.create! valid_attributes
      delete :destroy, {:id => course.to_param}, valid_session
      expect(response).to redirect_to(courses_url)
    end
  end

end