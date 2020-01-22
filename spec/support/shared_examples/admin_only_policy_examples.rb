# frozen_string_literal: true

RSpec.shared_examples 'AdminOnly Policy' do |options|
  options ||= {}
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: organization) }

  subject { described_class }

  actions = [:show?, :create?, :update?, :destroy?] - (options[:skip_actions] || [])

  actions.each do |action|
    permissions action do
      it "should not allow guest user to #{action}" do
        expect(subject).to_not permit(guest_user, subsite_record)
      end
  
      it "should not allow user to #{action}" do
        expect(subject).to_not permit(user, subsite_record)
      end
  
      it "should allow admin to #{action} at their own subsite" do
        expect(subject).to permit(admin, subsite_record)
      end
  
      it "should not allow admin to #{action} for another subsite" do
        expect(subject).to_not permit(admin, other_subsite_record)
      end
    end
  end
end
