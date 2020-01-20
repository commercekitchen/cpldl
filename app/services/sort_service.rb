# frozen_string_literal: true

class SortService
  def self.sort(model:, order_params:, attribute_key:, user:)
    order_params.each do |_k, v|
      record = model.find(v[:id])
      Pundit.policy!(user, record).update?
      record.update(attribute_key => v[:position])
    end
  end
end
