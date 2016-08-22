require "rails_helper"

describe Admin::ExportsController do
  before(:each) do
    @request.host = "chipublib.test.host"
    @admin = FactoryGirl.create(:admin_user)
    @organization = FactoryGirl.create(:organization)
    @admin.add_role(:admin, @organization)
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
      @user.add_role(:user, @organization)
      @user.profile = FactoryGirl.create(:profile)
      @language = FactoryGirl.create(:language)
      @course1 = FactoryGirl.create(:course, title: "Course 1",
                                             language: @language,
                                             description: "Mocha Java Scripta",
                                             organization: @organization)
      @course2 = FactoryGirl.create(:course, title: "Course 2",
                                             language: @language,
                                             organization: @organization)
      @course_progress1 = FactoryGirl.create(:course_progress, course_id: @course1.id, tracked: true, completed_at: Time.zone.now)
      @user.course_progresses << [@course_progress1]
    end
    it "return completions by zip" do
      returned = controller.data_for_completions_report_by_zip
      expect(returned).to eq({:version=>"zip", "90210"=>{:sign_ups=>1, :completions=>{"Course 1"=>0}}})
    end

    it "return completions by lib" do
      returned = controller.data_for_completions_report_by_lib
      # 1 is sample library Back of the Exports
      expect(returned).to eq({:version=>"lib", 1=>{:sign_ups=>1, :completions=>{"Course 1"=>0}}})
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