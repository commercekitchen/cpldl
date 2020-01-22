require 'rails_helper'

RSpec.describe LibraryLocationPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:library_location) { FactoryBot.create(:library_location, organization: organization) }
  let(:other_org_library_location) { FactoryBot.create(:library_location) }

  subject { described_class }

  permissions ".scope" do
    it 'should return organization library locations for guest user' do
      expect { Pundit.policy_scope!(guest_user, LibraryLocation) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should return organization library locations for non admin user' do
      expect { Pundit.policy_scope!(user, LibraryLocation) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should return organization library locations for admin' do
      scope = Pundit.policy_scope!(admin, LibraryLocation)
      expect(scope).to contain_exactly(library_location)
    end
  end

  permissions :show? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, library_location)
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, library_location)
      end
    end

    context 'admin' do
      it 'should be permitted for subsite location' do
        expect(subject).to permit(admin, library_location)
      end

      it 'should not be permitted for non subsite location' do
        expect(subject).to_not permit(admin, other_org_library_location)
      end
    end
  end

  permissions :create? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, LibraryLocation.new(organization: organization))
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, LibraryLocation.new(organization: organization))
      end
    end

    context 'admin' do
      it 'should be permitted for subsite location' do
        expect(subject).to permit(admin, LibraryLocation.new(organization: organization))
      end

      it 'should not be permitted for non subsite location' do
        expect(subject).to_not permit(admin, LibraryLocation.new)
      end
    end
  end

  permissions :update? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, library_location)
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, library_location)
      end
    end

    context 'admin' do
      it 'should be permitted for subsite location' do
        expect(subject).to permit(admin, library_location)
      end

      it 'should not be permitted for non subsite location' do
        expect(subject).to_not permit(admin, other_org_library_location)
      end
    end
  end

  permissions :destroy? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, library_location)
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, library_location)
      end
    end

    context 'admin' do
      it 'should be permitted for subsite location' do
        expect(subject).to permit(admin, library_location)
      end

      it 'should not be permitted for non subsite location' do
        expect(subject).to_not permit(admin, other_org_library_location)
      end
    end
  end
end
