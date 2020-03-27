# frozen_string_literal: true

require 'rails_helper'

describe Admin::CoursesController do
  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let(:topic) { FactoryBot.create(:topic) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'POST #create' do

    let(:existing_category) { FactoryBot.create(:category, organization: org) }

    let(:valid_attributes) do
      { title:  'Course you can',
        seo_page_title:  'Doo it | Foo it | Moo it ',
        meta_desc:  "You're so friggin meta",
        summary:  "Basically it's basic",
        description:  'More descriptive that you know!',
        contributor:  "MeMyself&I <a href='here.com'></a>",
        format: 'D',
        topic_ids: [topic.id],
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
        format: '',
        language_id: '',
        level: '',
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

      it 'assigns an existing topic' do
        expect do
          post :create, params: { course: valid_attributes }
        end.to change { topic.courses.count }.by(1)
      end

      it 'creates a new topic, if given' do
        valid_attributes[:course_topics_attributes] = [{ topic_attributes: { title: 'Some other topic' } }]
        expect do
          post :create, params: { course: valid_attributes }
        end.to change(Topic, :count).by(1)
      end

      it 'redirects to the admin edit view of the course' do
        post :create, params: { course: valid_attributes }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(edit_admin_course_path(Course.find_by(title: valid_attributes[:title])))
      end

      it 'redirects to the lesson edit page if specified' do
        post :create, params: { course: valid_attributes, commit: 'Save & Edit Lessons' }
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
        post :create, params: {
          course: valid_attributes.merge(
            category_id: '0',
            category_attributes: {
              name: existing_category.name,
              organization_id: org.id
            }
          )
        }
        expect(response).to render_template('new')
      end

      it 'publishes course if committed with publish' do
        expect do
          post :create, params: { course: valid_attributes.merge(pub_status: 'P') }
        end.to change { Course.where(pub_status: 'P').count }.by(1)
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
end
