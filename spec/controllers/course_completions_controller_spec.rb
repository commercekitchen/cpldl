require "rails_helper"

describe CourseCompletionsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:course1) { FactoryBot.create(:course, organization: organization) }
  let(:course2) { FactoryBot.create(:course, organization: organization) }
  let(:course3) { FactoryBot.create(:course, organization: organization) }
  let!(:language) { FactoryBot.create(:language) }

  before(:each) do
    request.host = "#{organization.subdomain}.example.com"
  end

  describe "GET #index" do
    context "when logged in" do
      let!(:course_progress1) { FactoryBot.create(:course_progress, course: course1, tracked: true, completed_at: Time.zone.now) }
      let!(:course_progress2) { FactoryBot.create(:course_progress, course: course2, tracked: true) }
      let!(:course_progress3) { FactoryBot.create(:course_progress, course: course3, tracked: true, completed_at: Time.zone.now) }

      before(:each) do
        user.course_progresses << [course_progress1, course_progress2, course_progress3]
        sign_in user
      end

      it "allows the user to view their completed courses" do
        get :index
        expect(assigns(:courses)).to include(course1, course3)
      end
    end

    context "when logged out" do
      it "should redirect to login page" do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

  describe "GET #show" do
    context "when logged in" do
      before(:each) do
        sign_in user
      end

      it "allows the user to view the complete view" do
        get :show, { course_id: course1 }
        expect(assigns(:course)).to eq(course1)
      end

      it "generates a PDF when send as format pdf" do
        # the send on this opens a term window on run
        get :show, { course_id: course1, format: "pdf" }
        expect(assigns(:pdf)).not_to be_empty
      end
    end

    context "when logged out" do
      it "should allow completion" do
        get :show, { course_id: course1 }
        expect(response).to have_http_status(:success)
        expect(assigns(:course)).to eq(course1)
      end
    end
  end
end
