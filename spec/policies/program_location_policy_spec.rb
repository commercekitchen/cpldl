require 'rails_helper'

RSpec.describe ProgramLocationPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:program) { FactoryBot.create(:program, organization: organization) }
  let(:other_subsite_program) { FactoryBot.create(:program) }
  let!(:program_location) { FactoryBot.create(:program_location, program: program) }
  let!(:other_org_program_location) { FactoryBot.create(:program_location, program: other_subsite_program) }

  subject { described_class }

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, ProgramLocation.new(program: program))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, ProgramLocation.new(program: program))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, ProgramLocation.new(program: program))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, ProgramLocation.new(program: other_subsite_program))
    end
  end

  permissions :update? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, program_location)
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, program_location)
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, program_location)
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, other_org_program_location)
    end
  end
end
