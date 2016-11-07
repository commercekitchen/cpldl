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

  describe "GET #new" do
    it "assigns a new program as @program" do
      get :new
      expect(assigns(:program)).to be_a_new(Program)
    end
  end

  describe "POST #create" do
    context "no location required" do
      let "valid_attributes" do
        {
          program_name: "dpl_edu",
          location_required: false
        }
      end

      let "invalid_attributes" do
        {
          program_name: ""
        }
      end

      context "valid params" do
        it "creates program with valid attributes" do
          expect do
            post :create, { program: valid_attributes }
          end.to change(Program, :count).by(1)
        end

        it "assigns program to @program" do
          post :create, { program: valid_attributes }
          expect(assigns(:program)).to be_a(Program)
          expect(assigns(:program)).to be_persisted
        end

        it "redirects to admin/programs" do
          post :create, { program: valid_attributes }

          expect(response).to redirect_to(admin_programs_path)
        end

        context "program location provided but not required" do
          it "does not create program location" do
            valid_attributes[:program_locations_attributes] = { 
              datetime_id_one: {
                location_name: "non_required_location"
              }
            }

            expect do
              post :create, { program: valid_attributes }
            end.not_to change(ProgramLocation, :count)
          end

          it "redirects to programs page" do
            valid_attributes[:program_locations_attributes] = { 
              datetime_id_one: {
                location_name: "non_required_location"
              }
            }

            post :create, { program: valid_attributes }
            expect(response).to redirect_to(admin_programs_path)
          end
        end
      end

      context "invalid_params" do
        it "doesn't create program with invalid attributes" do
          expect do
            post :create, { program: invalid_attributes }
          end.not_to change(Program, :count)
        end

        it "assigns new but unsaved program as @program" do
          post :create, { program: invalid_attributes }
          expect(assigns(:program)).to be_a_new(Program)
        end

        it "renders 'new' template" do
          post :create, { program: invalid_attributes }
          expect(response).to render_template "new"
        end
      end
    end

    context "location required" do
      let "valid_attributes" do
        {
          program_name: "dpl_edu",
          location_required: true,
          location_field_name: "neighborhoods",
          program_locations_attributes: {
            datetime_id_one: {
              location_name: "Highlands Ranch"
            },
            datetime_id_two: {
              location_name: "Lodo"
            }
          }
        }
      end

      let "invalid_attributes" do
        {
          program_name: "dpl_edu",
          location_required: true
        }
      end

      context "valid params" do
        it "creates a new program locations" do
          expect do
            post :create, { program: valid_attributes }
          end.to change(ProgramLocation, :count).by(2)
        end

        it "adds correct number of program locations to new program" do
          post :create, { program: valid_attributes }
          program = Program.last
          expect(program.program_locations.count).to eq 2 
        end

        it "creates correctly named program location" do
          post :create, { program: valid_attributes }
          program = Program.last
          expect(program.program_locations.first.location_name).to eq "Highlands Ranch"
        end
      end

      context "invalid params" do
        it "doesn't create program without location field name" do
          expect do
            post :create, { program: invalid_attributes }
          end.not_to change(Program, :count)
        end

        it "re-renders edit action without location field name" do
          post :create, { program: invalid_attributes }
          expect(response).to render_template "new"
        end

        it "doesn't create program without program location attributes" do
          invalid_attributes[:location_field_name] = "locations"

          expect do
            post :create, { program: invalid_attributes }
          end.not_to change(Program, :count)
        end

        it "re-renders edit action without location attributes" do
          invalid_attributes[:location_field_name] = "locations"

          post :create, { program: invalid_attributes }
          expect(response).to render_template "new"
        end
      end
    end
  end

  describe "GET #edit" do
    it "assigns requested program as @program" do
      get :edit, { id: @program1.to_param }
      expect(assigns(:program)).to eq(@program1)
    end
  end

  describe "POST #update" do
    context "no location originally required" do
      context "with valid params" do
        it "updates existing program" do
          current_attributes = @program1.attributes
          old_name = current_attributes["program_name"]
          current_attributes["program_name"] = old_name + "_new"
          patch :update, { id: @program1.to_param, program: current_attributes }
          @program1.reload
          expect(@program1.program_name).to eq old_name + "_new"
        end

        it "does not add locations if locations required not changed" do
          current_attributes = @program1.attributes
          current_attributes["program_locations_attributes"] = {
            datetime_id: {
              location_name: "ignore me"
            }
          }
          expect do
            patch :update, { id: @program1.to_param, program: current_attributes }
          end.not_to change(ProgramLocation, :count)
        end

        it "does add locations if locations required set to true" do
          current_attributes = @program1.attributes
          current_attributes["location_required"] = true
          current_attributes["location_field_name"] = "communities"
          current_attributes["program_locations_attributes"] = {
            datetime_id: {
              location_name: "don't ignore me"
            }
          }
          expect do
            patch :update, { id: @program1.to_param, program: current_attributes }
          end.to change(ProgramLocation, :count).by(1)
        end
      end

      context "with invalid params" do
        context "blank program name" do
          before do
            current_attributes = @program1.attributes
            @old_name = current_attributes["program_name"]
            current_attributes["program_name"] = ""
            patch :update, { id: @program1.to_param, program: current_attributes }
          end

          it "should not update name to blank" do
            @program1.reload
            expect(@program1.program_name).to eq @old_name
          end

          it "should re-render edit action" do
            expect(response).to render_template "edit"
          end
        end

        context "location required with blank location field name" do
          before do
            @current_attributes = @program1.attributes
            @current_attributes["location_required"] = true
            @current_attributes["location_field_name"] = ""
            @current_attributes["program_locations_attributes"] = {
              datetime_id: {
                location_name: "ignore me"
              }
            }
          end

          it "should not add program location" do
            expect do
              patch :update, { id: @program1.to_param, program: @current_attributes }
            end.not_to change(ProgramLocation, :count)
          end

          it "should re-render edit action" do
            patch :update, { id: @program1.to_param, program: @current_attributes }
            expect(response).to render_template "edit"
          end
        end

        context "location required with blank location name" do
          before do
            @current_attributes = @program1.attributes
            @current_attributes["location_required"] = true
            @current_attributes["location_field_name"] = "communities"
            @current_attributes["program_locations_attributes"] = {
              datetime_id: {
                location_name: ""
              }
            }            
          end

          it "should not add program location" do
            expect do
              patch :update, { id: @program1.to_param, program: @current_attributes }
            end.not_to change(ProgramLocation, :count)
          end

          it "should re-render edit action" do
            patch :update, { id: @program1.to_param, program: @current_attributes }
            expect(response).to render_template "edit"
          end
        end
      end
    end

    context "with location required" do
      context "with valid params" do
        before do
          @program2.program_locations << @location1
          @program2.program_locations << @location2
          @program2.update(location_field_name: "burroughs")
          @program2.update(location_required: true)
          @program2.reload

          @valid_attributes = @program2.attributes
          @valid_attributes[:program_locations_attributes] = {
            new_datetime_id_1: @location1.attributes,
            new_datetime_id_2: @location2.attributes
          }
        end

        context "new location field name" do
          it "changes location field name" do
            @valid_attributes[:location_field_name] = "quadrants"
            patch :update, { id: @program2, program: @valid_attributes }
            @program2.reload
            expect(@program2.location_field_name).to eq "quadrants"
          end

          it "doesn't change or remove program locations" do
            @valid_attributes[:location_field_name] = "quadrants"
            patch :update, { id: @program2, program: @valid_attributes }
            @program2.reload
            expect(@program2.program_locations).to include(@location1, @location2)
          end

          it "doesn't add new program locations" do
            @valid_attributes[:location_field_name] = "quadrants"
            patch :update, { id: @program2, program: @valid_attributes }
            @program2.reload
            expect(@program2.program_locations.count).to eq 2
          end
        end

        context "new program location data" do
          it "can remove a location" do
            # Not yet implemented
          end

          it "can edit a location name" do
            old_location_name = @location1.location_name
            @valid_attributes[:program_locations_attributes][:new_datetime_id_1] = {
              id: @location1.id,
              location_name: old_location_name + "_new"
            }
            patch :update, { id: @program2, program: @valid_attributes }
            @location1.reload
            expect(ProgramLocation.find(@location1.id).location_name).to eq old_location_name + "_new"
          end
        end
      end
    end
  end
end






