require "rails_helper"

describe CourseProgressesController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:language) { FactoryBot.create(:language) }
  let(:course1) { FactoryBot.create(:course, title: "Course 1", language: language) }
  let(:course2) { FactoryBot.create(:course, title: "Course 2", language: language) }
  let(:user) { FactoryBot.create(:user, organization: organization) }
  let(:lesson1) { create(:lesson, lesson_order: 1) }
  let(:lesson2) { create(:lesson, lesson_order: 2) }
  let(:lesson3) { create(:lesson, lesson_order: 3) }
  let(:lesson4) { create(:lesson) }

  before(:each) do
    course1.lessons << [lesson1, lesson2, lesson3]
    course2.lessons << [lesson4]
    request.host = "#{organization.subdomain}.example.com"
  end

  context "authenticated user" do

    before(:each) do
      sign_in user
    end

    describe "PUT #update" do
      it "creates a new course progress if none exists" do
        expect do
          put :update, { course_id: course1.id, tracked: "true" }
        end.to change(CourseProgress, :count).by(1)
      end

      it "marks an existing course progress as tracked" do
        progress = CourseProgress.create(user: user, course: course1, tracked: false)

        put :update, { course_id: course1.id, tracked: "true" }
        expect(progress.reload.tracked).to be true
      end

      it "marks an existing course as not tracked" do
        progress = CourseProgress.create(user: user, course: course1, tracked: true)

        put :update, { course_id: course1.id, tracked: "false" }
        expect(progress.reload.tracked).to be false
      end
    end

    describe "POST #start" do
      it "records that a user started a course" do
        post :create, { course_id: course1 }
        progress = user.course_progresses.last
        expect(progress.course_id).to eq(course1.id)
        expect(progress.tracked).to be true
        expect(response).to redirect_to(course_lesson_path(course1, course1.lessons.where(lesson_order: 1).first.id))
      end

      it "sends a user to the correct lesson if the course was already started" do
        user.course_progresses.create({ course_id: course1.id })
        user.course_progresses.first.completed_lessons.create({ lesson_id: lesson1.id })
        user.course_progresses.first.completed_lessons.create({ lesson_id: lesson2.id })
        post :create, { course_id: course1 }
        expect(response).to redirect_to(course_lesson_path(course1, lesson3.id))
      end

      it "only creates one course progress record per user per course" do
        expect(user.course_progresses.count).to eq(0)
        post :create, { course_id: course1 }
        expect(user.course_progresses.count).to eq(1)
        post :create, { course_id: course1 }
        expect(user.course_progresses.count).to eq(1)
        post :create, { course_id: course2 }
        expect(user.course_progresses.count).to eq(2)
        post :create, { course_id: course2 }
        expect(user.course_progresses.count).to eq(2)
      end
    end

  end

  context "non-authenticated user" do
    describe "POST #start" do
      it "should redirect to login page" do
        post :create, { course_id: course1 }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(course_lesson_path(course1, lesson1.id))
      end
    end

    describe "PUT #update" do
      it "should redirect to the login page" do
        put :update, { course_id: course1.id, tracked: "true" }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end
  end

end
