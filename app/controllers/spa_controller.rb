# frozen_string_literal: true

class SpaController < ApplicationController
  def index
    skip_authorization
    skip_policy_scope
    render :index, layout: 'spa'
  end
end
