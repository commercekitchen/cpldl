require "rails_helper"

describe CourseTrackingsController do
  let(:organization) { FactoryGirl.create(:organization) }
  let(:language) { FactoryGirl.create(:language) }
  let(:course) { FactoryGirl.create(:course, title: "Course 1", language: language) }
  let(:user) { FactoryGirl.create(:user, organization: organization) }

  context "authenticated user" do

    before(:each) do
      request.host = "#{organization.subdomain}.example.com"
      sign_in user
    end

    describe "PUT #update" do

      it "creates a new course progress if none exists" do
        expect do
          put :update, { course_id: course.id }
        end.to change(CourseProgress, :count).by(1)
      end

      it "marks an existing course progress as tracked" do
        progress = CourseProgress.create(user: user, course: course, tracked: false)

        post :update, { course_id: course.id }
        expect(progress.reload.tracked).to be true
      end

    end

    describe "DELETE #destroy" do

      it "marks a course as un-tracked" do
        progress = CourseProgress.create(user: user, course: course, tracked: true)

        delete :destroy, { course_id: course.id }
        expect(progress.reload.tracked).to be false
      end

    end

  end

  context "non-authenticated user" do
  end

end
