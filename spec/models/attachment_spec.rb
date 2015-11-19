# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  course_id             :integer
#  title                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#  doc_type              :string
#

require "rails_helper"

describe Attachment do

  context "verify validations" do

    before(:each) do
      @attachment = FactoryGirl.build(:attachment)
    end

    it "is initially valid" do
      expect(@attachment).to be_valid
    end

    it "can only have listed doc_types" do
      allowed_statuses = %w(supplemental post-course)
      allowed_statuses.each do |status|
        @attachment.doc_type = status
        expect(@attachment).to be_valid
      end

      @attachment.doc_type = ""
      expect(@attachment).to be_valid

      @attachment.doc_type = nil
      expect(@attachment).to be_valid

      @attachment.doc_type = "X"
      expect(@attachment).to_not be_valid
    end

  end

end
