# frozen_string_literal: true

class SortService
  def self.sort(model:, order_params:, attribute_key:)
    order_params.each do |_k, v|
      model.find(v[:id]).update(attribute_key => v[:position])
    end
  end
end
