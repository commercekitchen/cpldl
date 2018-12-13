require "rails_helper"

describe CourseProgressesController do
  let(:organization) { FactoryGirl.create(:organization) }
  let(:language) { FactoryGirl.create(:language) }
  let(:course) { FactoryGirl.create(:course, title: "Course 1", language: language) }
  let(:user) { FactoryGirl.create(:user, organization: organization) }

  before(:each) do
    request.host = "#{organization.subdomain}.example.com"
  end

  context "authenticated user" do

    before(:each) do
      sign_in user
    end

    describe "PUT #update" do

      it "creates a new course progress if none exists" do
        expect do
          put :update, { course_id: course.id, tracked: "true" }
        end.to change(CourseProgress, :count).by(1)
      end

      it "marks an existing course progress as tracked" do
        progress = CourseProgress.create(user: user, course: course, tracked: false)

        put :update, { course_id: course.id, tracked: "true" }
        expect(progress.reload.tracked).to be true
      end

      it "marks an existing course as not tracked" do
        progress = CourseProgress.create(user: user, course: course, tracked: true)

        put :update, { course_id: course.id, tracked: "false" }
        expect(progress.reload.tracked).to be false
      end

    end

  end

  context "non-authenticated user" do
    it "should redirect to the login page" do
      put :update, { course_id: course.id, tracked: "true" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(user_session_path)
    end
  end

end
