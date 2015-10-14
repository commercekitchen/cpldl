# require "rails_helper"

# RSpec.configure do |c|
#   c.infer_base_class_for_anonymous_controllers = false
# end

# class ApplicationController < ActionController::Base; end

# RSpec.describe ApplicationController do
#   controller do
#     def index; end

#   describe "#authorize" do
#     it "allows access" do
#       adminu = FactoryGirl.create(:user)
#       superu = FactoryGirl.create(:user)
#       adminu.add_role(:admin)
#       superu.add_role(:super)

#       sign_in(adminu)
#       expect(subject.authorize).to redirect_to(administrators_path)

#     end

#     it "refuses access" do
#     end
# end