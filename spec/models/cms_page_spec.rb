# frozen_string_literal: true

require 'rails_helper'

describe CmsPage do

  context 'verify validations' do
    let(:page) { FactoryBot.build(:cms_page) }

    it 'is initially valid' do
      expect(page).to be_valid
    end

    it 'should not allow two pages with the same title with in an organization' do
      page.save
      page2 = FactoryBot.build(:cms_page, organization: page.organization)
      expect(page2).to_not be_valid
      expect(page2.errors.full_messages.first).to eq('Title has already been taken for the organization')
    end

    it 'should require a title' do
      page.title = nil
      expect(page).to_not be_valid
    end

    it 'should require a body' do
      page.body = nil
      expect(page).to_not be_valid
    end

    it 'should require a language' do
      page.language_id = nil
      expect(page).to_not be_valid
    end

    it 'should have correct error message without language' do
      page.update(language_id: nil)
      expect(page.errors.full_messages).to contain_exactly("Language must exist")
    end

    it 'should require language id to numerical' do
      page.language_id = 'N'
      expect(page).to_not be_valid
    end

    it 'should require an author' do
      page.author = nil
      expect(page).to_not be_valid
    end

    it 'is valid with valid statuses' do
      allowed_statuses = %w[P D A]
      allowed_statuses.each do |status|
        page.pub_status = status
        expect(page).to be_valid
      end
    end

    describe 'publication status validations' do
      it 'is invalid with empty string publication status' do
        page.pub_status = ''
        expect(page).to_not be_valid
      end

      it 'has correct error message with empty string publication status' do
        page.update(pub_status: '')
        expect(page.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'is invalid with nil publication status' do
        page.pub_status = nil
        expect(page).to_not be_valid
      end

      it 'has correct error message for nil publication status' do
        page.update(pub_status: nil)
        expect(page.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'is invalid with invalid publication status' do
        page.pub_status = 'X'
        expect(page).to_not be_valid
      end

      it 'has correct error message for invalid publication status' do
        page.update(pub_status: 'X')
        expect(page.errors.full_messages).to contain_exactly("Publication Status X is not a valid status")
      end
    end

    it 'should initially be set to draft status' do
      expect(page.pub_status).to eq('D')
    end

    it 'does not set pub date if status is not Published' do
      expect(page.set_pub_date).to be(nil)
    end

    it 'should set pub date on publication' do
      page.pub_status = 'P'
      expect(page.set_pub_date.to_i).to eq(Time.zone.now.to_i)
    end

    it 'should update the pub date with status change' do
      page.pub_status = 'P'
      expect(page.set_pub_date).to_not be(nil)
      page.pub_status = 'D'
      expect(page.update_pub_date(page.pub_status)).to be(nil)
      page.pub_status = 'P'
      expect(page.update_pub_date(page.pub_status).to_i).to be(Time.zone.now.to_i)
    end

    it 'humanizes publication status' do
      expect(page.current_pub_status).to eq('Draft')
      page.pub_status = 'P'
      expect(page.current_pub_status).to eq('Published')
      page.pub_status = 'A'
      expect(page.current_pub_status).to eq('Archived')
    end

    it 'is valid with valid audiences' do
      allowed_audiences = %w[Unauth Auth Admin All]
      allowed_audiences.each do |audience|
        page.audience = audience
        expect(page).to be_valid
      end
    end

    describe 'audience validations' do
      it 'is invalid with empty string audience' do
        page.audience = ''
        expect(page).to_not be_valid
      end

      it 'has correct error message with empty string audience' do
        page.update(audience: '')
        expect(page.errors.full_messages).to contain_exactly("Audience can't be blank")
      end

      it 'is invalid with nil audience' do
        page.audience = nil
        expect(page).to_not be_valid
      end

      it 'has correct error message for nil audience' do
        page.update(audience: nil)
        expect(page.errors.full_messages).to contain_exactly("Audience can't be blank")
      end

      it 'is invalid with invalid audience' do
        page.audience = 'foobar'
        expect(page).to_not be_valid
      end

      it 'has correct error message for invalid audience' do
        page.update(audience: 'foobar')
        expect(page.errors.full_messages).to contain_exactly("Audience foobar is not a valid audience")
      end
    end

    it 'should not require the seo page title' do
      page.seo_page_title = ''
      expect(page).to be_valid
    end

    it 'seo page title cannot be longer than 90 chars' do
      valid_title = (0...90).map { ('a'..'z').to_a[rand(26)] }.join
      page.seo_page_title = valid_title
      expect(page).to be_valid

      invalid_title = (0...91).map { ('a'..'z').to_a[rand(26)] }.join
      page.seo_page_title = invalid_title
      expect(page).to_not be_valid
    end

    it 'should not require the meta description' do
      page.seo_page_title = ''
      expect(page).to be_valid
    end

    it 'meta description cannot be longer than 156 chars' do
      valid_meta = (0...156).map { ('a'..'z').to_a[rand(26)] }.join
      page.meta_desc = valid_meta
      expect(page).to be_valid

      invalid_meta = (0...157).map { ('a'..'z').to_a[rand(26)] }.join
      page.meta_desc = invalid_meta
      expect(page).to_not be_valid
    end
  end
end
