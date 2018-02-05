class StaticController < ApplicationController
	layout "application" # Force this layout, which has the needed sub_callout.
	before_action :redirect_to_www

	def customization
	end

	def overview
	end

	def portfolio
	end
end