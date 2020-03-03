# frozen_string_literal: true

require 'rails_helper'

describe Admin::CoursesController do
  let(:org) { FactoryBot.create(:organization) }
  let(:other_org) { FactoryBot.create(:organization, subdomain: 'dpl') }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let(:category1) { FactoryBot.create(:category, organization: org) }
  let(:category2) { FactoryBot.create(:category, organization: org) }
  let(:category3) { FactoryBot.create(:category, organization: other_org) }
  let!(:course1) { FactoryBot.create(:course, title: 'Course1', course_order: 1, category: category1, organization: org) }
  let!(:course2) { FactoryBot.create(:course, title: 'Course2', course_order: 2, category: category2, organization: org) }
  let!(:course3) { FactoryBot.create(:course, title: 'Course3', course_order: 3, organization: org) }
  let!(:course_for_different_org) { create(:course, title: 'Different Org', organization: other_org) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #index' do
    before(:each) do
      get :index, params: { subdomain: 'chipublib' }
    end

    it 'assigns all courses as @courses' do
      expect(assigns(:courses)).to include(course1, course2, course3)
    end

    it 'only assigns correct number of courses' do
      expect(assigns(:courses).count).to eq(3)
    end

    it 'assigns category_ids' do
      expect(assigns(:category_ids)).to include(category1.id, category2.id)
    end

    it 'only assigns proper category ids' do
      expect(assigns(:category_ids).count).to eq(2)
    end

    it 'assigns uncategorized_courses' do
      expect(assigns(:uncategorized_courses)).to include(course3)
    end

    it 'only assigns uncategorized courses' do
      expect(assigns(:uncategorized_courses).count).to eq(1)
    end
  end

  describe 'GET #new' do
    it 'assigns a new course as @course' do
      get :new
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe 'GET #preview' do
    let(:pla) { FactoryBot.create(:default_organization) }
    let(:pla_course) { FactoryBot.create(:course, organization: pla) }

    it 'assigns the requested course as @course' do
      get :preview, params: { course_id: pla_course.to_param }
      expect(assigns(:course)).to eq(pla_course)
    end

    it 'renders course show' do
      get :preview, params: { course_id: pla_course.to_param }
      expect(response).to render_template('courses/show')
    end
  end

  describe 'PATCH #update_pub_status' do
    it 'updates the status' do
      patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'P' }
      course1.reload
      expect(course1.pub_status).to eq('P')
    end

    it 'updates the pub_date if status is published' do
      Timecop.freeze do
        patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'A' }
        course1.reload
        expect(course1.pub_date).to be(nil)

        patch :update_pub_status, params: { course_id: course1.id.to_param, value: 'P' }
        course1.reload
        expect(course1.pub_date.to_i).to eq(Time.zone.now.to_i)
      end
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested course as @course' do
      get :edit, params: { id: course1.to_param }
      expect(assigns(:course)).to eq(course1)
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      { title:  'Course you can',
        seo_page_title:  'Doo it | Foo it | Moo it ',
        meta_desc:  "You're so friggin meta",
        summary:  "Basically it's basic",
        description:  'More descriptive that you know!',
        contributor:  "MeMyself&I <a href='here.com'></a>",
        pub_status:  'P',
        format: 'D',
        other_topic_text: 'Learning',
        language_id: @english.id,
        level: 'Advanced',
        course_order: '',
        organization_id: org.id }
    end

    let(:invalid_attributes) do
      { title: '',
        seo_page_title: '',
        meta_desc: '',
        summary: '',
        description: '',
        contributor: '',
        pub_status: '',
        format: '',
        language_id: '',
        level: '',
        other_topic_text: '',
        course_order: '',
        organization_id: org.id }
    end

    context 'with valid params' do
      it 'creates a new Course' do
        expect do
          post :create, params: { course: valid_attributes }
        end.to change(Course, :count).by(1)
      end

      it 'assigns a newly created course as @course' do
        post :create, params: { course: valid_attributes }
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end

      it 'creates a new topic, if given' do
        valid_attributes[:other_topic] = '1'
        valid_attributes[:other_topic_text] = 'Some other topic'
        post :create, params: { course: valid_attributes }
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
        expect(assigns(:course).topics.last.title).to include('Some other topic')
      end

      it 'redirects to the admin edit view of the course' do
        post :create, params: { course: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_admin_course_lesson_path(Course.find_by(title: valid_attributes[:title])))
      end

      it 'adds an existing category if provided' do
        category = FactoryBot.create(:category, organization: org)
        post :create, params: { course: valid_attributes.merge(category_id: category.id) }
        expect(assigns(:course).category).to eq(category)
      end

      it 'creates and adds category if new category selected' do
        expect do
          post :create, params: {
            course: valid_attributes.merge(
              category_id: '0',
              category_attributes: {
                name: Faker::Lorem.word,
                organization_id: org.id
              }
            )
          }
        end.to change(Category, :count).by(1)

        expect(assigns(:course).category).not_to be_nil
      end

      it 're-reders new if repeat category name' do
        @existing_category = FactoryBot.create(:category, organization: org)
        post :create, params: {
          course: valid_attributes.merge(
            category_id: '0',
            category_attributes: {
              name: @existing_category.name,
              organization_id: org.id
            }
          )
        }
        expect(response).to render_template('new')
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved course as @course' do
        post :create, params: { course: invalid_attributes }
        expect(assigns(:course)).to be_a_new(Course)
      end

      it "re-renders the 'new' template" do
        post :create, params: { course: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST #update' do
    context 'with valid params' do
      let(:course1_attributes) do
        course1.attributes.merge(access_level: 'everyone', category_id: category2.id)
      end

      it 'updates an existing Course' do
        patch :update, params: { id: course1.to_param, course: course1_attributes, commit: 'Save Course' }
        expect(response).to redirect_to(edit_admin_course_path(course1))
      end

      it 'displays appropriate notice for successful course update' do
        patch :update, params: { id: course1.to_param, course: course1_attributes, commit: 'Save Course' }
        expect(flash[:notice]).to eq('Course was successfully updated.')
      end

      it 'updates an existing Course, and moves on to lessons' do
        patch :update, params: { id: course1.to_param, course: course1_attributes, commit: 'Save Course and Add Lessons' }
        expect(response).to redirect_to(new_admin_course_lesson_path(course1, course1.lessons.first))
      end

      it 'creates a new topic, if given' do
        valid_attributes = course1_attributes
        valid_attributes[:other_topic] = '1'
        valid_attributes[:other_topic_text] = 'Another new topic'
        patch :update, params: { id: course1.to_param, course: valid_attributes }
        expect(assigns(:course).topics.last.title).to include('Another new topic')
      end

      describe 'propagation' do
        let(:org2) { FactoryBot.create(:organization) }
        let(:update_params) do
          { id: course1.to_param,
            course: course1_attributes.merge(propagation_org_ids: [org2.id], title: 'Test Course'),
            commit: 'Save Course' }
        end

        before do
          course2.update(organization: org2, parent_id: course1.id)
          course1.update(propagation_org_ids: [org2])
        end

        it 'propagates changes to selected courses' do
          patch :update, params: update_params
          course2.reload
          expect(course2.title).to eq('Test Course')
        end

        it 'displays propagation success message' do
          patch :update, params: update_params
          expect(flash[:notice]).to eq('Course was successfully updated. Changes propagated to courses for 1 subsite.')
        end

        it 'creates a new category on org2' do
          expect do
            patch :update, params: update_params
          end.to change { org2.categories.count }.by(1)
        end

        it 'does not assign course to main site category' do
          expect do
            patch :update, params: update_params
          end.to_not(change { category2.courses.count })
        end

        describe 'new category' do
          let(:new_category_params) do
            { id: course1.to_param,
              course: { category_id: '0',
                        category_attributes: { name: 'New Category', organization_id: org.id },
                        propagation_org_ids: [org2.id] },
              commit: 'Save Course' }
          end

          it 'should create a new category in originating org' do
            expect do
              patch :update, params: new_category_params
            end.to change { org.categories.count }.by(1)
          end

          it 'should create a new category in subsite org' do
            expect do
              patch :update, params: new_category_params
            end.to change { org2.categories.count }.by(1)
          end
        end
      end
    end
  end

  describe 'POST #sort' do
    it 'should change course order' do
      order_params = { '0' => { id: course2.id, position: 1 }, '1' => { id: course1.id, position: 2 } }
      post :sort, params: { order: order_params }
      expect(course1.reload.course_order).to eq(2)
      expect(course2.reload.course_order).to eq(1)
    end
  end
end
