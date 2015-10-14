class Course < ActiveRecord::Base
  
  has_many :course_topics
  has_many :topics, through: :course_topics

  belongs_to :language

  has_many :attachments, dependent: :destroy
  accepts_nested_attributes_for :attachments, reject_if: proc { |a| a[:document].blank? }, allow_destroy: true

  # has_many :lessons
  # has_one :assessment

  validates :title, 
            :seo_page_title, 
            :meta_desc, 
            :summary, 
            :description, 
            :contributor, 
            :pub_status, 
            :language_id, 
            :level, presence: true

  def topics_list(topic_list)
    if topic_list
      valid_topics = topic_list.reject do |topic|
       topic.blank?
      end

      new_or_found_topics = valid_topics.map do |title|
        Topic.find_or_create_by(title: title)
      end

      self.topics = new_or_found_topics
    end
  end
end