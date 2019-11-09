# frozen_string_literal: true

require 'rails_helper'

describe Contact do

  context 'validations' do

    before :each do
      @contact = FactoryBot.create(:contact)
    end

    it 'should initially be valid' do
      expect(@contact.valid?).to be true
    end

    it 'should require first_name' do
      @contact.update(first_name: '')
      expect(@contact.valid?).to be false
    end

    it 'should require first_name to be less than 30 characters' do
      str = 'a' * 30
      @contact.update(first_name: str)
      expect(@contact.valid?).to be true

      @contact.update(first_name: str + 'a')
      expect(@contact.valid?).to be false
    end

    it 'should require last_name' do
      @contact.update(last_name: '')
      expect(@contact.valid?).to be false
    end

    it 'should require last_name to be less than 30 characters' do
      str = 'a' * 30
      @contact.update(last_name: str)
      expect(@contact.valid?).to be true

      @contact.update(last_name: str + 'a')
      expect(@contact.valid?).to be false
    end

    it 'should require organization' do
      @contact.update(organization: '')
      expect(@contact.valid?).to be false
    end

    it 'should require organization to be less than 50 characters' do
      str = 'a' * 50
      @contact.update(organization: str)
      expect(@contact.valid?).to be true

      @contact.update(organization: str + 'a')
      expect(@contact.valid?).to be false
    end

    it 'should require city' do
      @contact.update(city: '')
      expect(@contact.valid?).to be false
    end

    it 'should require organization to be less than 50 characters' do
      str = 'a' * 50
      @contact.update(organization: str)
      expect(@contact.valid?).to be true

      @contact.update(organization: str + 'a')
      expect(@contact.valid?).to be false
    end

    it 'should require state' do
      @contact.update(state: '')
      expect(@contact.valid?).to be false
    end

    it 'should require email' do
      @contact.update(email: '')
      expect(@contact.valid?).to be false
    end

    it 'should require an email extension' do
      @contact.update(email: 'alex@commercekitchen')
      expect(@contact.valid?).to be false
    end

    it 'should not allow an email to end in a comma' do
      @contact.update(email: 'alex@commercekitchen.co,')
      expect(@contact.valid?).to be false
    end

    it 'should correctly handle a exception causing entry' do
      @contact.update(email: '@')
      expect(@contact.valid?).to be false
    end

    it 'should require phone to be less than 20 characters' do
      str = 'a' * 20
      @contact.update(phone: str)
      expect(@contact.valid?).to be true

      @contact.update(phone: str + 'a')
      expect(@contact.valid?).to be false
    end

    it 'should require comments' do
      @contact.update(comments: '')
      expect(@contact.valid?).to be false
    end

    it 'should require comments to be less than 2048 characters' do
      str = 'a' * 2048
      @contact.update(comments: str)
      expect(@contact.valid?).to be true

      @contact.update(comments: str + 'a')
      expect(@contact.valid?).to be false
    end

  end

  context '#full_name' do

    it 'should concatenate the first and last name' do
      @contact = create(:contact)
      expect(@contact.full_name).to eq 'Alan Turing'
    end

  end

  context '#city_state' do

    it 'should concatenate the first and last name' do
      @contact = create(:contact)
      expect(@contact.city_state).to eq 'New York, NY'
    end

  end

end
