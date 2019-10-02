require "rails_helper"

describe Admin::ProgramsController do

  before(:each) do
    @organization = create(:organization, subdomain: "dpl")
    @request.host = "dpl.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @admin = create(:user, :admin, organization: @organization)
    @program1 = create(:program, organization: @organization)
    @program2 = create(:program, organization: @organization)
    @location1 = create(:program_location, program: @program2)
    @location2 = create(:program_location, program: @program2)
    sign_in @admin
  end

  describe "GET #new" do
    it "assigns program" do
      get :new
      expect(assigns(:program)).to be_a_new(Program)
    end
  end

  describe "POST #create" do
    it "creates new program" do
      expect do
        post :create, program: { program_name: "New Program", location_required: false, parent_type: "seniors" }
      end.to change(Program, :count).by(1)
    end

    it "creates program with locations" do
      post :create, program: { program_name: "Locations Program", location_required: true, parent_type: "young_adults" }
      expect(Program.last.program_name).to eq "Locations Program"
      expect(Program.last.location_required).to be true
      expect(Program.last.parent_type).to eq "young_adults"
    end

    it "creates program with no locations" do
      post :create, program: { program_name: "No Locations Program", location_required: false, parent_type: "students_and_parents" }
      expect(Program.last.program_name).to eq "No Locations Program"
      expect(Program.last.location_required).to be false
      expect(Program.last.parent_type).to eq "students_and_parents"
    end
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
