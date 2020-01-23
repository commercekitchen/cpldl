# frozen_string_literal: true

RSpec.shared_examples 'AdminOnly Policy' do |options|
  options ||= {}

  let(:model) { options[:model] }
  let(:model_symbol) { model.name.underscore.to_sym }
  let(:subsite) { try(:organization) || FactoryBot.create(:organization) }

  let!(:authorized_record) { try(:subsite_record) || FactoryBot.create(model_symbol, organization: subsite) }
  let!(:unauthorized_record) { try(:other_subsite_record) || FactoryBot.create(model_symbol) }

  let(:guest_user) { GuestUser.new(organization: subsite) }
  let(:user) { FactoryBot.create(:user, organization: subsite) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: subsite) }

  subject { described_class }

  actions = %i[show? create? update? destroy?] - (options[:skip_actions] || [])

  actions.each do |action|
    permissions action do
      it "should not allow guest user to #{action}" do
        expect(subject).to_not permit(guest_user, authorized_record)
      end

      it "should not allow user to #{action}" do
        expect(subject).to_not permit(user, authorized_record)
      end

      it "should allow admin to #{action} at their own subsite" do
        expect(subject).to permit(admin, authorized_record)
      end

      it "should not allow admin to #{action} for another subsite" do
        expect(subject).to_not permit(admin, unauthorized_record)
      end
    end
  end

  unless options[:skip_scope]
    permissions '.scope' do
      before do
        # Note: this seems to be required for some models (ex/ Category), but not others, to work
        subsite.reload
      end

      it 'should raise error for guest user' do
        expect { Pundit.policy_scope!(guest_user, model) }.to raise_error(Pundit::NotAuthorizedError)
      end

      it 'should raise error for user' do
        expect { Pundit.policy_scope!(user, model) }.to raise_error(Pundit::NotAuthorizedError)
      end

      it 'should list correct objects for admin' do
        expect(Pundit.policy_scope!(admin, model)).to contain_exactly(authorized_record)
      end
    end
  end
end
