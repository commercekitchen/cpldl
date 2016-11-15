require "rails_helper"

describe Admin::ProgramsController do

  before(:each) do
    @organization = create(:organization, subdomain: "dpl")
    @request.host = "dpl.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @admin = create(:admin_user, organization: @organization)
    @admin.add_role(:admin, @organization)
    @program1 = create(:program, organization: @organization)
    @program2 = create(:program, organization: @organization)
    @location1 = create(:program_location, program: @program2)
    @location2 = create(:program_location, program: @program2)
    sign_in @admin
  end

  describe "GET #index" do
    it "assigns all programs as @programs" do
      get :index
      expect(assigns(:programs)).to include(@program1, @program2)
      expect(assigns(:programs).count).to eq(2)
    end
  end

  describe "GET #edit" do
    it "assigns requested program as @program" do
      get :edit, { id: @program1.to_param }
      expect(assigns(:program)).to eq(@program1)
    end
  end

end






