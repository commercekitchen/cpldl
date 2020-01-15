# frozen_string_literal: true

require 'rails_helper'

describe ContactMailer, type: :mailer do
  let(:contact) { FactoryBot.create(:contact) }

  describe '#email' do
    let(:email) { described_class.email(contact.id) }

    it 'should include contact name in the body' do
      expect(email.body.encoded).to match(contact.full_name)
    end

    it 'should send email to the correct person' do
      expect(email.to).to contain_exactly('sallen@ala.org')
    end
  end
end
