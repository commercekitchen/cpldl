class Administrators::BaseController < ApplicationController
  before_action :authorize
end
