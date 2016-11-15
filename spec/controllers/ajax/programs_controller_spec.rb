require "rails_helper"

describe Ajax::ProgramsController do

  before do
    @organization = create(:organization, subdomain: "dpl")
    @request.host = "dpl.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @program = create(:program, organization: @organization)
    @program_location = create(:program_location, program: @program)
  end

  describe "POST #select_program" do
    it "should assign correct program" do
      post :select_program, { program_id: @program.id, format: "json" }
      expect(assigns(:program)).to eq @program
    end

    it "should respond with program and locations" do
      post :select_program, { program_id: @program.id, format: "json" }
      expect(response.body).to include(@program.program_name)
      expect(response.body).to include(@program_location.location_name)
    end
  end

end