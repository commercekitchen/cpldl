# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:program) { FactoryBot.create(:program, organization: organization) }
  let!(:other_org_program) { FactoryBot.create(:program) }

  subject { described_class }

  permissions '.scope' do
    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, Program) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, Program) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct programs for admin' do
      expect(Pundit.policy_scope!(admin, Program)).to contain_exactly(program)
    end
  end

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, Program.new(organization: organization))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, Program.new(organization: organization))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, Program.new(organization: organization))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, Program.new)
    end
  end

  permissions :update? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, program)
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, program)
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, program)
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, other_org_program)
    end
  end

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, program)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, program)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, program)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_program)
    end
  end
end
