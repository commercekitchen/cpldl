module Static
  class BaseController < ApplicationController
    layout "application" # Force this layout, which has the needed sub_callout.
    before_action :redirect_to_www
  end
end
