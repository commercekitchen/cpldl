# == Schema Information
#
# Table name: cms_pages
#
#  id             :integer          not null, primary key
#  title          :string(90)
#  author         :string
#  page_type      :string
#  audience       :string
#  pub_status     :string           default("D")
#  pub_date       :datetime
#  seo_page_title :string(90)
#  meta_desc      :string(156)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  slug           :string
#  cms_page_order :integer
#

require "rails_helper"

describe CmsPage do

  context "verify validations" do

    before(:each) do
      @page = FactoryGirl.build(:cms_page)
      @page.contents << FactoryGirl.create(:content)
    end

    it "is initially valid" do
      expect(@page).to be_valid
    end

    it "should not allow two pages with the same title" do
      @page.save
      @page2 = FactoryGirl.build(:cms_page)
      expect(@page2).to_not be_valid
      expect(@page2.errors.full_messages.first).to eq("Title has already been taken")
    end

    it "can only have listed statuses" do
      allowed_statuses = %w(P D T)
      allowed_statuses.each do |status|
        @page.pub_status = status
        expect(@page).to be_valid
      end

      @page.pub_status = ""
      expect(@page).to_not be_valid

      @page.pub_status = nil
      expect(@page).to_not be_valid

      @page.pub_status = "X"
      expect(@page).to_not be_valid
    end

    it "should initially be set to draft status" do
      expect(@page.pub_status).to eq("D")
    end

    it "does not set pub date if status is not Published" do
      expect(@page.set_pub_date).to be(nil)
    end

    it "should set pub date on publication" do
      @page.pub_status = "P"
      expect(@page.set_pub_date.to_i).to eq(Time.zone.now.to_i)
    end

    it "should update the pub date with status change" do
      @page.pub_status = "P"
      expect(@page.set_pub_date).to_not be(nil)
      @page.pub_status = "D"
      expect(@page.update_pub_date(@page.pub_status)).to be(nil)
      @page.pub_status = "P"
      expect(@page.update_pub_date(@page.pub_status).to_i).to be(Time.zone.now.to_i)
    end

    it "humanizes publication status" do
      expect(@page.current_pub_status).to eq("Draft")
      @page.pub_status = "P"
      expect(@page.current_pub_status).to eq("Published")
      @page.pub_status = "T"
      expect(@page.current_pub_status).to eq("Trashed")
    end

    it "should not require the seo page title" do
      @page.seo_page_title = ""
      expect(@page).to be_valid
    end

    it "seo page title cannot be longer than 90 chars" do
      valid_title = (0...90).map { ("a".."z").to_a[rand(26)] }.join
      @page.seo_page_title = valid_title
      expect(@page).to be_valid

      invalid_title = (0...91).map { ("a".."z").to_a[rand(26)] }.join
      @page.seo_page_title = invalid_title
      expect(@page).to_not be_valid
    end

    it "should not require the meta description" do
      @page.seo_page_title = ""
      expect(@page).to be_valid
    end

    it "meta description cannot be longer than 156 chars" do
      valid_meta = (0...156).map { ("a".."z").to_a[rand(26)] }.join
      @page.meta_desc = valid_meta
      expect(@page).to be_valid

      invalid_meta = (0...157).map { ("a".."z").to_a[rand(26)] }.join
      @page.meta_desc = invalid_meta
      expect(@page).to_not be_valid
    end
  end
end
