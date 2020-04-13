# frozen_string_literal: true

require 'rails_helper'

describe Attachment do

  context 'verify validations' do

    before(:each) do
      @attachment = FactoryBot.build(:attachment)
    end

    it 'is initially valid' do
      expect(@attachment).to be_valid
    end

    it 'can only have listed doc_types' do
      allowed_statuses = %w[text-copy additional-resource]
      allowed_statuses.each do |status|
        @attachment.doc_type = status
        expect(@attachment).to be_valid
      end

      @attachment.doc_type = ''
      expect(@attachment).to be_valid

      @attachment.doc_type = nil
      expect(@attachment).to be_valid

      @attachment.doc_type = 'X'
      expect(@attachment).to_not be_valid
    end

  end

end
