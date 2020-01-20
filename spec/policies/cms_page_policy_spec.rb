require 'rails_helper'

RSpec.describe CmsPagePolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let!(:cms_page) { FactoryBot.create(:cms_page, organization: organization) }
  let!(:other_org_cms_page) { FactoryBot.create(:cms_page) }

  subject { described_class }

  permissions ".scope" do
    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, CmsPage) }

      it 'should be empty' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'authenticated user' do
      let(:scope) { Pundit.policy_scope!(user, CmsPage) }

      it 'should be empty' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'admin user' do
      let(:scope) { Pundit.policy_scope!(admin, CmsPage) }

      it 'should contain all cms pages for organization' do
        expect(scope).to contain_exactly(cms_page)
      end
    end
  end

  permissions :show? do
    context 'guest user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(guest_user, cms_page)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(guest_user, other_org_cms_page)
      end
    end

    context 'authenticated user' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(user, cms_page)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(user, other_org_cms_page)
      end
    end

    context 'admin' do
      it 'should be permitted for current organization' do
        expect(subject).to permit(admin, cms_page)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(admin, other_org_cms_page)
      end
    end
  end

  permissions :create? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, CmsPage.new(organization: organization))
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, CmsPage.new(organization: organization))
      end
    end

    context 'admin' do
      it 'should be permitted for admin organization' do
        expect(subject).to permit(admin, CmsPage.new(organization: organization))
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(admin, CmsPage.new)
      end
    end
  end

  permissions :update? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, cms_page)
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, cms_page)
      end
    end

    context 'admin' do
      it 'should be permitted for admin organization' do
        expect(subject).to permit(admin, cms_page)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(admin, other_org_cms_page)
      end
    end
  end

  permissions :destroy? do
    context 'guest user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(guest_user, cms_page)
      end
    end

    context 'authenticated user' do
      it 'should not be permitted' do
        expect(subject).to_not permit(user, cms_page)
      end
    end

    context 'admin' do
      it 'should be permitted for admin organization' do
        expect(subject).to permit(admin, cms_page)
      end

      it 'should not be permitted for another organization' do
        expect(subject).to_not permit(admin, other_org_cms_page)
      end
    end
  end
end
