# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FooterLink, type: :model do
  let(:link) { FactoryBot.build(:footer_link) }

  it 'is valid initially' do
    expect(link).to be_valid
  end

  it 'should require a label' do
    link.label = nil
    expect(link).not_to be_valid
  end

  it 'should require a url' do
    link.url = nil
    expect(link).not_to be_valid
  end

  it 'should require an organization' do
    link.organization = nil
    expect(link).not_to be_valid
  end

  it 'should require a language' do
    link.language = nil
    expect(link).not_to be_valid
  end

  it 'prepends scheme if missing' do
    link.url = 'www.example.com'
    link.save
    expect(link.reload.url).to eq('https://www.example.com')
  end

  it 'accepts footer links with scheme' do
    link.url = 'http://www.example.com'
    link.save
    expect(link.reload.url).to eq('http://www.example.com')
  end

  it 'handles whitespace' do
    link.url = ' https://www.example.com/'
    link.save
    expect(link.reload.url).to eq('https://www.example.com/')
  end
end
