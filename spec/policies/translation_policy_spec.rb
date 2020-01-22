# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranslationPolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:guest_user) { GuestUser.new(organization: organization) }
  let(:admin) { FactoryBot.create(:user, :admin) }
  let(:translation) { FactoryBot.create(:translation) }

  subject { described_class }

  describe 'Scope' do
    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, :translation) }

      it 'should raise an authorization error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'subsite user' do
      let(:scope) { Pundit.policy_scope!(user, :translation) }

      it 'should raise an authorization error' do
        expect { scope }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'subsite admin' do
      let(:scope) { Pundit.policy_scope!(admin, :translation) }

      it 'should display all translations' do
        expect(scope).to contain_exactly(translation)
      end
    end
  end
end
