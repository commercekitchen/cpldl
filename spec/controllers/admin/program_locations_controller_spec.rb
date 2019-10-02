require "rails_helper"

describe Admin::ProgramLocationsController do

  before(:each) do
    @organization = create(:organization, subdomain: "dpl")
    @request.host = "dpl.test.host"
    @english = create(:language)
    @spanish = create(:spanish_lang)
    @admin = create(:user, :admin, organization: @organization)
    @program1 = create(:program, :location_required, organization: @organization)
    @program2 = create(:program, organization: @organization)
    @location_enabled = create(:program_location, program: @program1)
    @location_disabled = create(:program_location, :disabled, program: @program1)
    sign_in @admin
  end

  describe "POST #create" do
    it "should create new program location" do
      valid_attributes = {
        location_name: "SoDoSoPa",
        program_id: @program1.id
      }

      expect do
        post :create, params: { program_location: valid_attributes, format: "js" }
      end.to change(ProgramLocation, :count).by(1)
    end
  end

  describe "POST #toggle" do
    it "should disable enabled program location" do
      expect(@location_enabled.enabled).to be true
      post :toggle, params: { program_location_id: @location_enabled, format: "js" }
      @location_enabled.reload
      expect(@location_enabled.enabled).to be false
    end

    it "should enable disabled program location" do
      expect(@location_disabled.enabled).to be false
      post :toggle, params: { program_location_id: @location_disabled, format: "js" }
      @location_disabled.reload
      expect(@location_disabled.enabled).to be true
    end
  end

end
