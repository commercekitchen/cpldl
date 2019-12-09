# frozen_string_literal: true

require 'rails_helper'

describe SortService do
  let(:course) { FactoryBot.create(:course) }
  let(:lesson1) { FactoryBot.create(:lesson, course: course) }
  let(:lesson2) { FactoryBot.create(:lesson, course: course, lesson_order: 2) }

  it 'should order lessons properly' do
    order_params = { '0' => { id: lesson1.id, position: 2 }, '1' => { id: lesson2.id, position: 1 } }
    SortService.sort(model: Lesson, order_params: order_params, attribute_key: :lesson_order)
    expect(lesson1.reload.lesson_order).to eq(2)
    expect(lesson2.reload.lesson_order).to eq(1)
  end
end
