# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramLocationPolicy, type: :policy do
  let(:organization) { FactoryBot.create(:organization) }
  let(:program) { FactoryBot.create(:program, organization: organization) }
  let(:other_subsite_program) { FactoryBot.create(:program) }
  let!(:subsite_record) { FactoryBot.create(:program_location, program: program) }
  let!(:other_subsite_record) { FactoryBot.create(:program_location, program: other_subsite_program) }

  it_behaves_like 'AdminOnly Policy', { skip_scope: true }
end
