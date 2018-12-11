module Courses
  class CompletionsController < ApplicationController
    before_action :authorize_user!

    def index
    end

  end
end