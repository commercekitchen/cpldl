# frozen_string_literal: true

require 'rails_helper'

describe Constants do

  it 'should return 51 values for US states (50 + DC)' do
    expect(Constants.us_states.count).to eq 51
  end

end
