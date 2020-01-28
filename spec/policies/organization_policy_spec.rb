# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationPolicy, type: :policy do
  let(:www) { FactoryBot.create(:default_organization) }
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:subsite_admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:www_admin) { FactoryBot.create(:user, :admin, organization: www) }

  subject { described_class }

  permissions '.scope' do
    it 'should raise authorization error for guest user' do
      expect { Pundit.policy_scope!(guest_user, Organization) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise authorization error for user' do
      expect { Pundit.policy_scope!(user, Organization) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise authorization error for subsite admin' do
      expect { Pundit.policy_scope!(subsite_admin, Organization) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list organizations for www admin' do
      scope = Pundit.policy_scope!(www_admin, Organization)
      expect(scope).to contain_exactly(www, organization)
    end
  end

  permissions :customize? do
    context 'guest user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, organization)
      end
    end

    context 'subsite user' do
      it 'denies access' do
        expect(subject).to_not permit(user, organization)
      end
    end

    context 'subsite admin' do
      it 'allows access for admin organization' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for other organizations' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end

  permissions :get_recommendations? do
    context 'guest user' do
      it 'denies access for another organization' do
        expect(subject).to_not permit(guest_user, Organization.new)
      end

      it 'allows access for user subsite' do
        expect(subject).to permit(guest_user, organization)
      end
    end

    context 'user' do
      it 'allows access for user subsite' do
        expect(subject).to permit(user, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(user, Organization.new)
      end
    end

    context 'subsite admin' do
      it 'allows access for user subsite' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end

  permissions :update? do
    context 'guest user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, organization)
      end
    end

    context 'user' do
      it 'denies access' do
        expect(subject).to_not permit(user, organization)
      end
    end

    context 'subsite admin' do
      it 'allows access for user subsite' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end

  permissions :import_courses? do
    context 'guest user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, organization)
      end
    end

    context 'user' do
      it 'denies access' do
        expect(subject).to_not permit(user, organization)
      end
    end

    context 'subsite admin' do
      it 'allows access for user subsite' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end

  permissions :download_reports? do
    context 'guest user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, organization)
      end
    end

    context 'user' do
      it 'denies access' do
        expect(subject).to_not permit(user, organization)
      end
    end

    context 'subsite admin' do
      it 'allows access for user subsite' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end

  permissions :invite_user? do
    context 'guest user' do
      it 'denies access' do
        expect(subject).to_not permit(guest_user, organization)
      end
    end

    context 'user' do
      it 'denies access' do
        expect(subject).to_not permit(user, organization)
      end
    end

    context 'subsite admin' do
      it 'allows access for user subsite' do
        expect(subject).to permit(subsite_admin, organization)
      end

      it 'denies access for another organization' do
        expect(subject).to_not permit(subsite_admin, Organization.new)
      end
    end
  end
end
