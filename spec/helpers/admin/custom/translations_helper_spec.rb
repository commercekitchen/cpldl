# frozen_string_literal: true

require 'rails_helper'

describe Admin::Custom::TranslationsHelper do
  let(:org) { FactoryBot.create(:organization) }
  let(:subdomain) { org.subdomain }

  before do
    @request.host = "#{org.subdomain}.test.host"
  end

  describe '#translation_keys' do
    let(:expected_keys) do
      ["home.#{subdomain}.custom_banner_greeting",
       "home.choose_a_course.#{subdomain}",
       "home.choose_course_subheader.#{subdomain}",
       "completed_courses_page.#{subdomain}.retake_the_quiz"]
    end

    it 'should return correct english translation keys' do
      expect(helper.translation_keys('en').keys).to match_array(expected_keys)
    end

    it 'should return correct spanish translation keys' do
      expect(helper.translation_keys('es').keys).to match_array(expected_keys)
    end
  end

  describe '#translation_for_key' do
    let!(:translation) { Translation.create(locale: 'en', key: 'foo', value: 'bar') }
    let!(:other_translation) { Translation.create(locale: 'en', key: 'foo', value: 'baz') }

    it 'should find first translation by key' do
      expect(helper.translation_for_key(Translation.locale(:en), 'foo')).to eq(translation)
    end
  end

  describe '#locale_string' do
    it 'should return Spanish if es' do
      expect(helper.locale_string(:es)).to eq('Spanish')
    end

    it 'should return English if en' do
      expect(helper.locale_string(:en)).to eq('English')
    end

    it 'should return English if not en or es' do
      expect(helper.locale_string(:foobar)).to eq('English')
    end
  end

  describe '#default_org_i18n_key' do
    let(:key) { helper.translation_keys('en').keys.first }

    it 'should replace subdomain with default org in key' do
      expect(helper.default_org_i18n_key(key)).to_not match(org.subdomain)
      expect(helper.default_org_i18n_key(key)).to match('default_org')
    end
  end

  describe '#i18n_with_default' do
    before do
      FactoryBot.create(:organization, subdomain: 'foobar')
      @request.host = 'foobar.test.host'
    end

    it 'should return translation with default' do
      key = 'home.foobar.custom_banner_greeting'
      default_translation = I18n.t('home.default_org.custom_banner_greeting')
      expect(helper.i18n_with_default(key)).to eq(default_translation)
    end
  end
end
