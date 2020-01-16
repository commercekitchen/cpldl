require 'rails_helper'

RSpec.describe ContactPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:main_site) { FactoryBot.create(:default_organization) }
  let(:guest_user) { GuestUser.new(organization: main_site) }

  subject { described_class }

  permissions :create? do
    let(:contact) { Contact.new }

    it 'allows guest user' do
      expect(subject).to permit(guest_user, contact)
    end

    it 'allows user' do
      expect(subject).to permit(user, contact)
    end
  end
end
