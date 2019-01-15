require "rails_helper"

describe HomeController do

  before(:each) do
    @www = create(:default_organization)
    @request.host = "www.test.host"
    @spanish = create(:spanish_lang)
    @english = create(:language)

    @category1 = create(:category, organization: @www)
    @category2 = create(:category, organization: @www)
    @disabled_category = create(:category, :disabled, organization: @www)

    @category1_course = create(:course_with_lessons, organization: @www, category: @category1, display_on_dl: true, language: @english)
    @category2_course = create(:course_with_lessons, organization: @www, category: @category2, display_on_dl: true, language: @english)
    @disabled_category_course = create(:course_with_lessons, organization: @www, category: @disabled_category, display_on_dl: true, language: @english)
    @uncategorized_course = create(:course_with_lessons, organization: @www, display_on_dl: true, language: @english)
  end

  describe "#index" do
    before(:each) do
      get :index
    end

    it "responds successfully" do
      expect(response).to have_http_status(:success)
    end

    it "assigns enabled category ids" do
      expect(assigns(:category_ids)).to include(@category1.id, @category2.id)
    end

    it "only assigns enabled category ids" do
      expect(assigns(:category_ids).length).to eq(2)
    end

    it "assigns uncategorized and disabled category courses to uncategorized" do
      expect(assigns(:uncategorized_courses)).to include(@disabled_category_course, @uncategorized_course)
    end

    it "assigns correct number of uncategorized courses" do
      expect(assigns(:uncategorized_courses).count).to eq(2)
    end
  end

end
