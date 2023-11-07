class UpdatePastQuizResponses < ActiveRecord::Migration[5.2]
  def up
    User.where.not(quiz_responses_object: nil).each do |u|
      next if u.quiz_responses_object.empty?

      old_responses = u.quiz_responses_object
      new_responses = {}

      new_responses['desktop_level'] = level_string_from_number_response(old_responses['set_one']) if old_responses['set_one'].present?
      new_responses['mobile_level'] = level_string_from_number_response(old_responses['set_two']) if old_responses['set_two'].present?
      new_responses['topic'] = topic_from_number_response(old_responses['set_three']) if old_responses['set_three'].present?

      u.update(quiz_responses_object: new_responses)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def level_string_from_number_response(old_response)
    case old_response
    when '1'
      'Beginner'
    when '2'
      'Intermediate'
    when '3'
      'Advanced'
    when '4'
      'Expert'
    end
  end

  def topic_from_number_response(old_response)
    key = topic_map[old_response]

    if key.present?
      topic = Topic.find_by(translation_key: key)
      raise MissingTopicError if topic.blank?
      return topic.id.to_s
    else
      raise UnknownTopicResponseError("Unrecognized topic respose: #{old_response}")
    end
  end

  def topic_map
    {
      '1' => 'job_search',
      '2' => 'education_child',
      '3' => 'govt',
      '4' => 'education_adult',
      '5' => 'communication_social_media',
      '6' => 'security',
      '7' => 'software_apps',
      '8' => 'information_searching'
    }
  end

  class UnknownTopicResponseError < StandardError; end;
  class MissingTopicError < StandardError; end;
end
