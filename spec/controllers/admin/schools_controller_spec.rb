require "rails_helper"

describe Admin::SchoolsController do

  before(:each) do
    @organization = create(:organization, subdomain: "dpl")
    @request.host = "dpl.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @admin = create(:user, :admin, organization: @organization)

    @school_enabled = create(:school, organization: @organization)
    @school_disabled = create(:school, :disabled, organization: @organization)
    sign_in @admin
  end

  describe "GET #index" do
    it "assigns schools for organization" do
      get :index
      expect(assigns(:schools).count).to eq(2)
      expect(assigns(:schools).first).to eq(@school_enabled)
      expect(assigns(:schools).second).to eq(@school_disabled)
    end

    it "creates new empty school" do
      get :index
      expect(assigns(:new_school)).to be_a_new(School)
    end
  end

  describe "POST #create" do
    it "should create new school with valid attributes" do
      valid_attributes = {
        school_name: "Lincoln Elementary"
      }

      expect do
        post :create, params: { school: valid_attributes, format: "js" }
      end.to change(School, :count).by(1)
    end
  end

  describe "POST #toggle" do
    it "should disable enabled school" do
      expect(@school_enabled.enabled).to be true
      post :toggle, params: { school_id: @school_enabled, format: "js" }
      @school_enabled.reload
      expect(@school_enabled.enabled).to be false
    end

    it "should enable disabled school" do
      expect(@school_disabled.enabled).to be false
      post :toggle, params: { school_id: @school_disabled, format: "js" }
      @school_disabled.reload
      expect(@school_disabled.enabled).to be true
    end
  end

end
