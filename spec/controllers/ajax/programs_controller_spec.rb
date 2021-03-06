# frozen_string_literal: true

require 'rails_helper'

describe Ajax::ProgramsController do
  let(:organization) { create(:organization, subdomain: 'dpl') }

  before do
    @request.host = "#{organization.subdomain}.test.host"
  end

  describe 'POST #sub_programs' do
    before do
      @program = create(:program, organization: organization)
      create(:program, organization: organization, active: false)
      create(:program)

      @student_program1 = create(:program, :student_program, organization: organization)
      @student_program2 = create(:program, :student_program, organization: organization)
      create(:program, :student_program, organization: organization, active: false)

      @young_adult_program = create(:program, :young_adult_program, organization: organization)
      create(:program, :young_adult_program, organization: organization, active: false)
    end

    it 'should assign senior programs' do
      post :sub_programs, params: { parent_type: 'seniors', format: 'json' }
      expect(assigns(:programs)).to contain_exactly(@program)
    end

    it 'should assign school programs' do
      post :sub_programs, params: { parent_type: 'students_and_parents', format: 'json' }
      expect(assigns(:programs)).to contain_exactly(@student_program1, @student_program2)
    end

    it 'should assign young adult programs' do
      post :sub_programs, params: { parent_type: 'young_adults', format: 'json' }
      expect(assigns(:programs)).to contain_exactly(@young_adult_program)
    end

    it 'should respond with correct programs' do
      post :sub_programs, params: { parent_type: 'students_and_parents', format: 'json' }
      expect(response.body).to include(@student_program1.program_name)
    end
  end

  describe 'POST #select_program' do
    let(:program) { create(:program, organization: organization) }

    it 'should assign correct program' do
      post :select_program, params: { program_id: program.id, format: 'json' }
      expect(assigns(:program)).to eq program
    end

    it 'should respond with program and locations' do
      program_location = create(:program_location, program: program)

      post :select_program, params: { program_id: program.id, format: 'json' }
      expect(response.body).to include(program.program_name)
      expect(response.body).to include(program_location.location_name)
    end
  end

end
