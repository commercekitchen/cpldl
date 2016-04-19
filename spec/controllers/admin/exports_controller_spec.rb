require "rails_helper"

describe Admin::ExportsController do
  before(:each) do
    @request.host = "www.test.host"
    @admin = FactoryGirl.create(:admin_user)
    @admin.add_role(:admin)
    sign_in @admin
    @zip_csv = { format: "csv", version: "zip" }
  end


  describe "#completions" do
    it "respond to csv" do
      get :completions, @zip_csv
      expect(response.body).to_not be(nil)
      expect(response.body).to eq("Zip Code,Sign-Ups(total),Course Title,Completions\n")
    end
  end

  describe "#data_for_completions_report_by_zip" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @organization = FactoryGirl.create(:organization)
      @user.add_role(:user, @organization)
      sign_in @user
      @language = FactoryGirl.create(:language)
      @course1 = FactoryGirl.create(:course, title: "Course 1",
                                             language: @language,
                                             description: "Mocha Java Scripta",
                                             organization: @organization)
      @course2 = FactoryGirl.create(:course, title: "Course 2",
                                             language: @language,
                                             organization: @organization)
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true)
      @course_progress2 = FactoryGirl.create(:course_progress, course_id: @course2.id, tracked: false)
      @user.course_progresses << [@course_progress1, @course_progress2]
    end
    it "return completions by zip" do
      get :completions, @zip_csv
      binding.pry
    end
  end
end



  # describe "Method #render_bad_request =>" do
  #   controller do
  #     attr_accessor :user
  #     def index
  #       render_bad_request user.errors.messages
  #     end
  #   end
  #   before(:each) { controller.user = User.create }
  #   it "Renders the correct error messages" do
  #     get :index
  #     parsed_body = JSON.parse(response.body)['errors']
  #     expect(parsed_body).to eq(controller.user.errors.messages.stringify_keys)
  #   end
  #   it "Renders the error message json with the correct status code" do
  #     get :index
  #     expect(response.status).to be(400)
  #   end
  # end