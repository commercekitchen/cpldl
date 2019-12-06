# frozen_string_literal: true

require 'rails_helper'

describe Devise::Mailer, type: :mailer do
  describe '#invitation_instructions' do
    let(:organization) { FactoryBot.create(:organization) }
    let(:user) { FactoryBot.create(:user, organization: organization) }
    let(:token) { Faker::Lorem.characters(number: 10) }
    let(:mail) { Devise::Mailer.invitation_instructions(user, token) }

    it 'should include correct link in body' do
      expect(mail.body.encoded).to match("#{organization.subdomain}.test.host")
    end

    describe 'custom host' do
      before do
        ActionMailer::Base.default_url_options[:host] = 'new.custom.host'
        ActionDispatch::Http::URL.tld_length = 2
      end

      after do
        ActionMailer::Base.default_url_options[:host] = 'test.host'
        ActionDispatch::Http::URL.tld_length = 1
      end

      it 'should include correct link in body with different host' do
        expect(mail.body.encoded).to match("#{organization.subdomain}.new.custom.host")
      end
    end
  end
end