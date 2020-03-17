# frozen_string_literal: true

require 'rails_helper'

describe Course do
  context 'validations' do
    let(:org) { create(:organization) }
    let(:course) { FactoryBot.build(:course, organization: org) }
    let(:draft_course) { FactoryBot.create(:draft_course) }

    it 'is initially valid' do
      expect(course).to be_valid
    end

    it 'should not allow two published courses with the same title within organization' do
      FactoryBot.create(:course, title: course.title, organization: org, pub_status: 'P')
      course.validate

      expect(course.errors.messages.empty?).to be(false)
      expect(course.errors.messages[:title].first).to eq('has already been taken for the organization')
    end

    it 'should not allow two draft courses with the same title within organization' do
      FactoryBot.create(:course, title: course.title, organization: org, pub_status: 'D')
      expect(course).to_not be_valid
    end

    it 'should allow duplicate course titles across organizations' do
      FactoryBot.create(:course, title: course.title)
      expect(course).to be_valid
    end

    it 'should allow a new course with duplicate name if original is archived' do
      FactoryBot.create(:course, title: course.title, organization: org, pub_status: 'A')
      expect(course).to be_valid
    end

    it 'should save new course with duplicate name if original is archived' do
      FactoryBot.create(:course, title: course.title, organization: org, pub_status: 'A')
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

    describe 'invalid publication statuses' do
      it 'should not allow empty string for publication status' do
        course.pub_status = ''
        expect(course).to_not be_valid
      end

      it 'has correct error message with empty string publication status' do
        course.update(pub_status: '')
        expect(course.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'should not allow nil for publication status' do
        course.pub_status = nil
        expect(course).to_not be_valid
      end

      it 'has correct error message for nil publication status' do
        course.update(pub_status: nil)
        expect(course.errors.full_messages).to contain_exactly("Publication Status can't be blank")
      end

      it 'should not allow invalid publication status' do
        course.pub_status = 'X'
        expect(course).to_not be_valid
      end

      it 'has correct error message for invalid publication status' do
        course.update(pub_status: 'X')
        expect(course.errors.full_messages).to contain_exactly('Publication Status X is not a valid status')
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

    it 'should initially be set to published status' do
      expect(draft_course.pub_status).to eq('D')
    end

    it 'does not set pub date if status is not Published' do
      expect(draft_course.set_pub_date).to be(nil)
    end

    it 'should set pub date on publication' do
      Timecop.freeze do
        course.pub_status = 'P'
        expect(course.set_pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end

    it 'should update the pub date with status change' do
      Timecop.freeze do
        course.pub_status = 'P'
        expect(course.set_pub_date).to_not be(nil)
        course.pub_status = 'D'
        expect(course.update_pub_date(course.pub_status)).to be(nil)
        course.pub_status = 'P'
        expect(course.update_pub_date(course.pub_status).to_i).to be(Time.zone.now.to_i)
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
  end
end
