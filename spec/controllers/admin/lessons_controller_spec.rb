require "rails_helper"

describe Admin::LessonsController do

  before(:each) do
    @request.host = "www.test.host"
    create(:organization, subdomain: "www")
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @course1 = create(:course)
    @lesson1 = create(:lesson, title: "Lesson1")
    @lesson2 = create(:lesson, title: "Lesson2")
    @course1.lessons << [@lesson1, @lesson2]
    @course1.save

    @admin = create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
  end

  # => not yet implemented <=

  # describe "GET #index" do
  #   it "assigns all lessons for a given course as @lessons" do
  #     get :index, course_id: @course1.to_param
  #     expect(assigns(:lessons).count).to eq(2)
  #     expect(assigns(:lessons).first).to eq(@lesson1)
  #     expect(assigns(:lessons).second).to eq(@lesson2)
  #   end

  #   it "responds to json" do
  #     get :index, course_id: @course1.to_param, format: :json
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  describe "GET #edit" do
    it "assigns the requested lesson as @lesson" do
      get :edit, { course_id: @course1.to_param, id: @lesson1.id.to_param }
      expect(assigns(:lesson)).to eq(@lesson1)
    end
  end

  describe "GET #new" do
    it "assigns a new lesson as @lesson" do
      get :new, { course_id: @course1.to_param }
      expect(assigns(:lesson)).to be_a_new(Lesson)
    end
  end

  describe "POST #create" do
    before(:each) do
      @story_line = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/BasicSearch1.zip"), "application/zip")
    end

    after(:each) do
      FileUtils.remove_dir "#{Rails.root}/public/storylines/3", true
    end

    let(:valid_attributes) do
      { duration: "01:20",
        title:  "Lesson your load man",
        seo_page_title:  "Seo | Beo | Meo ",
        meta_desc:  "Its good to Meta-Tate",
        summary:  "Sum-tings-smelly",
        is_assessment: false,
        story_line: @story_line,
        pub_status: "P"
      }
    end

    let(:assessment_attributes) do
      { duration: "01:20",
        title:  "I am an assessment",
        seo_page_title:  "See | Bee | Mee ",
        meta_desc:  "is this like inception",
        summary:  "Sum-tings-smelly",
        is_assessment: true,
        story_line: @story_line,
        pub_status: "P"
      }
    end

    let(:invalid_attributes) do
      { duration: "",
        title:  "",
        seo_page_title:  "",
        meta_desc:  "",
        summary:  "",
        is_assessment: "",
        story_line: nil,
        pub_status: nil
      }
    end

    context "with valid params" do
      it "creates a new lesson" do
        expect do
          post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        end.to change(Lesson, :count).by(1)
      end

      it "creates a new assessment" do
        expect do
          post :create, { course_id: @course1.to_param, lesson: assessment_attributes }
        end.to change(Lesson, :count).by(1)
      end

      it "assigns a new assessment to the end of the course lessons" do
        post :create, { course_id: @course1.to_param, lesson: assessment_attributes }
        lesson = Lesson.last
        expect(lesson.lesson_order).to be(3)
      end

      it "renders new if an assessment already exists" do
        post :create, { course_id: @course1.to_param, lesson: assessment_attributes }
        expect(@course1.lessons.count).to eq(3)
        post :create, { course_id: @course1.to_param, lesson: assessment_attributes, title: "something different" }
        expect(@course1.lessons.count).to eq(3)
      end

      it "assigns a new lesson as @lesson" do
        post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        expect(assigns(:lesson)).to be_a(Lesson)
        expect(assigns(:lesson)).to be_persisted
      end

      it "redirects to the admin edit view of the lesson" do
        post :create, { course_id: @course1.to_param, lesson: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("http://www.test.host/admin/courses/#{@course1.slug}/lessons/lesson-your-load-man/edit")
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved lesson as @lesson" do
        post :create, { course_id: @course1.to_param, lesson: invalid_attributes }
        expect(assigns(:lesson)).to be_a_new(Lesson)
      end

      it "re-renders the 'new' template" do
        post :create, { course_id: @course1.to_param, lesson: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST #update" do
    context "with valid params" do
      it "updates an existing Lesson" do
        patch :update,
          { course_id: @course1.to_param, id: @lesson1.to_param, lesson: @lesson1.attributes, commit: "Save Lesson" }
        expect(response).to have_http_status(:redirect)
      end

      it "updates with duration as a string" do
        @lesson_attributes = @lesson1.attributes
        @lesson_attributes["duration"] = "1:00"
        patch :update,
          { course_id: @course1.to_param, id: @lesson1.to_param, lesson: @lesson_attributes, commit: "Save Lesson" }
        expect(response).to have_http_status(:redirect)
      end

      it "propagates updates to child lessons" do
        org = create(:organization)
        @lesson2.course.organization = org
        @lesson2.save
        @lesson1.propagation_org_ids = [org.id]
        @lesson2.update(parent_id: @lesson1.id)
        patch :update,
              { course_id: @course1.to_param, id: @lesson1.to_param, lesson: @lesson1.attributes.merge(propagation_org_ids: [org.id], title: "Test Lesson"), commit: "Save Lesson" }

        @lesson2.reload
        expect(@lesson2.title).to eq("Test Lesson")
      end
    end
  end

end
