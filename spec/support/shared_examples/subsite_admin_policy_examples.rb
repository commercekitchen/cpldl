RSpec.shared_examples "Subsite Admin Examples" do |tested_class|
  let(:model_symbol) { tested_class.name.underscore.to_sym }
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }
  let!(:record) { FactoryBot.create(model_symbol, organization: organization) }
  let!(:other_org_record) { FactoryBot.create(model_symbol) }

  subject { described_class }

  permissions ".scope" do
    it 'should raise error for guest user' do
      expect { Pundit.policy_scope!(guest_user, tested_class) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should raise error for user' do
      expect { Pundit.policy_scope!(user, tested_class) }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'should list correct records for admin' do
      organization.reload
      expect(Pundit.policy_scope!(admin, tested_class)).to contain_exactly(record)
    end
  end

  permissions :create? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, tested_class.new(organization: organization))
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, tested_class.new(organization: organization))
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, tested_class.new(organization: organization))
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, tested_class.new)
    end
  end

  permissions :update? do
    it 'should not allow guest user to create' do
      expect(subject).to_not permit(guest_user, record)
    end

    it 'should not allow user to create' do
      expect(subject).to_not permit(user, record)
    end

    it 'should allow admin to create at their own org' do
      expect(subject).to permit(admin, record)
    end

    it 'should not allow admin to create for another org' do
      expect(subject).to_not permit(admin, other_org_record)
    end
  end

  permissions :destroy? do
    it 'should not allow guest user to destroy' do
      expect(subject).to_not permit(guest_user, record)
    end

    it 'should not allow user to destroy' do
      expect(subject).to_not permit(user, record)
    end

    it 'should allow admin to destroy at their own org' do
      expect(subject).to permit(admin, record)
    end

    it 'should not allow admin to destroy for another org' do
      expect(subject).to_not permit(admin, other_org_record)
    end
  end
end