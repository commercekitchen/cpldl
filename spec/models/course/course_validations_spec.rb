# frozen_string_literal: true

require 'rails_helper'

describe Course do
  context 'validations' do
    let(:org) { create(:organization) }
    let(:course) { FactoryBot.build(:course, organization: org) }
    let(:draft_course) { FactoryBot.create(:course) }

    it 'is initially valid' do
      expect(course).to be_valid
    end

    it 'should not allow two published courses with the same title within organization' do
      FactoryBot.create(:course, :published, title: course.title, organization: org)
      course.validate

      expect(course.errors.messages.empty?).to be(false)
      expect(course.errors.messages[:title].first).to eq('has already been taken for the organization')
    end

    it 'should not allow two draft courses with the same title within organization' do
      FactoryBot.create(:course, :published, title: course.title, organization: org)
      expect(course).to_not be_valid
    end

    it 'should allow duplicate course titles across organizations' do
      FactoryBot.create(:course, title: course.title)
      expect(course).to be_valid
    end

    it 'should allow a new course with duplicate name if original is archived' do
      FactoryBot.create(:course, :archived, title: course.title, organization: org)
      expect(course).to be_valid
    end

    it 'should save new course with duplicate name if original is archived' do
      FactoryBot.create(:course, :archived, title: course.title, organization: org)
      expect(course.save).to be_truthy
    end

    it 'should allow 50 character titles' do
      course.title = 'a' * 50
      expect(course).to be_valid
    end

    it 'should not allow >50 character titles' do
      course.title = 'a' * 51
      expect(course).to_not be_valid
    end

    it 'is valid with a valid publication status' do
      allowed_statuses = %w[P D A]
      allowed_statuses.each do |status|
        course.pub_status = status
        expect(course).to be_valid
      end
    end

    it 'is valid with valid formats' do
      allowed_formats = %w[D M]
      allowed_formats.each do |format|
        course.format = format
        expect(course).to be_valid
      end
    end

    it 'can be coming_soon if draft' do
      course.publication_status = :draft
      course.coming_soon = true
      expect(course).to be_valid
    end

    it 'cannot be coming_soon unless in draft status' do
      course.publication_status = :published
      course.coming_soon = true
      expect(course).not_to be_valid
    end

    describe 'invalid publication statuses' do
      it 'should not allow empty string for publication status' do
        course.publication_status = ''
        expect(course).to_not be_valid
      end

      it 'has correct error message with empty string publication status' do
        course.update(publication_status: '')
        expect(course.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'should not allow nil for publication status' do
        course.publication_status = nil
        expect(course).to_not be_valid
      end

      it 'has correct error message for nil publication status' do
        course.update(publication_status: nil)
        expect(course.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end
    end

    describe 'invalid formats' do
      it 'should not allow empty string for format' do
        course.format = ''
        expect(course).to_not be_valid
      end

      it 'has correct error message for empty string format' do
        course.format = ''
        course.save
        expect(course.errors.full_messages).to contain_exactly("Format can't be blank")
      end

      it 'should not allow nil for format' do
        course.format = nil
        expect(course).to_not be_valid
      end

      it 'has correct error message for nil format' do
        course.format = ''
        course.save
        expect(course.errors.full_messages).to contain_exactly("Format can't be blank")
      end

      it 'should not allow invalid format' do
        course.format = 'Y'
        expect(course).to_not be_valid
      end

      it 'has correct error message for invalid format' do
        course.format = 'Y'
        course.save
        expect(course.errors.full_messages).to contain_exactly('Format Y is not a valid format')
      end
    end

    it 'should not require the seo page title' do
      course.seo_page_title = ''
      expect(course).to be_valid
    end

    it 'seo page title cannot be longer than 90 chars' do
      valid_title = (0...90).map { ('a'..'z').to_a[rand(26)] }.join
      course.seo_page_title = valid_title
      expect(course).to be_valid

      invalid_title = (0...91).map { ('a'..'z').to_a[rand(26)] }.join
      course.seo_page_title = invalid_title
      expect(course).to_not be_valid
    end

    it 'should not require the meta description' do
      course.seo_page_title = ''
      expect(course).to be_valid
    end

    it 'meta description cannot be longer than 156 chars' do
      valid_meta = (0...156).map { ('a'..'z').to_a[rand(26)] }.join
      course.meta_desc = valid_meta
      expect(course).to be_valid

      invalid_meta = (0...157).map { ('a'..'z').to_a[rand(26)] }.join
      course.meta_desc = invalid_meta
      expect(course).to_not be_valid
    end

    describe 'Draft courses' do
      let(:course) do
        Course.new(publication_status: 'draft',
                   title: 'Some Title',
                   language: @english,
                   organization: org)
      end

      it 'is valid with only a title and language' do
        expect(course).to be_valid
      end

      it 'requires a title' do
        course.title = nil
        expect(course).not_to be_valid
      end

      it 'requires a language' do
        course.language = nil
        expect(course).not_to be_valid
      end
    end
  end
end
