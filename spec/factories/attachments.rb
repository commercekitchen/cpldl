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
#  file_description      :string
#

FactoryGirl.define do
  factory :attachment do
    document_file_name "post-course-info.pdf"
    document_content_type "application/pdf"
    document_file_size 22
    document_updated_at "2015-10-10 20:00:00"
  end
end
