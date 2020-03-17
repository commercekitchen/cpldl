# frozen_string_literal: true

require 'rails_helper'

describe Admin::CoursesController do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:pla_admin) { FactoryBot.create(:user, :admin, organization: pla) }
  let(:pla_category1) { FactoryBot.create(:category, organization: pla) }
  let(:pla_category2) { FactoryBot.create(:category, organization: pla) }
  let(:pla_course) { FactoryBot.create(:course, organization: pla, title: 'PLA Course', category: pla_category1) }

  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let!(:child_course) { FactoryBot.create(:course, title: 'Child Course', parent: pla_course, organization: org, pub_status: 'D') }

  describe 'POST #update' do
    context 'pla course' do
      before(:each) do
        @request.host = "#{pla.subdomain}.test.host"
        sign_in pla_admin
      end

      let(:update_params) do
        pla_course.attributes.merge('title' => 'Updated Title', 'access_level' => 'authenticated_users', 'category_id' => pla_category2.id)
      end

      let(:new_topic_params) do
        update_params.merge(course_topics_attributes: [{ topic_attributes: { title: 'Another new topic' } }])
      end

      let(:publish_request) do
        patch :update, params: { id: pla_course.to_param, course: update_params, commit: 'Publish Course' }
      end

      it 'redirects to edit path' do
        publish_request
        expect(response).to redirect_to(edit_admin_course_path(pla_course.reload))
      end

      it 'updates title' do
        expect do
          publish_request
        end.to change { pla_course.reload.title }.from('PLA Course').to('Updated Title')
      end

      it 'updates access level' do
        expect do
          publish_request
        end.to change { pla_course.reload.access_level }.from('everyone').to('authenticated_users')
      end

      it 'updates category' do
        expect do
          publish_request
        end.to change { pla_course.reload.category }.from(pla_category1).to(pla_category2)
      end

      it 'displays appropriate notice for successful course update' do
        publish_request
        expect(flash[:notice]).to eq('Course was successfully updated.')
      end

      it 'redirects to lesson edit page if desired' do
        patch :update, params: { id: pla_course.to_param, course: update_params, commit: 'Edit Lessons' }
        expect(response).to redirect_to(new_admin_course_lesson_path(pla_course.reload, pla_course.lessons.first))
      end

      it 'creates a new topic, if given' do
        expect do
          patch :update, params: { id: pla_course.to_param, course: new_topic_params }
        end.to change(Topic, :count).by(1)
      end

      describe 'propagation' do
        it 'propagates title to child courses' do
          expect do
            publish_request
          end.to change { child_course.reload.title }.to('Updated Title')
        end

        it 'propagates topic to child courses' do
          expect do
            patch :update, params: { id: pla_course.to_param, course: new_topic_params }
          end.to(change { child_course.reload.topics })
        end

        it 'does not assign course to main site category' do
          expect do
            publish_request
          end.to_not(change { child_course.reload.category })
        end

        it 'does not change child course access level' do
          expect do
            publish_request
          end.to_not(change { child_course.reload.access_level })
        end

        describe 'new category' do
          let(:new_category_params) do
            { id: pla_course.to_param,
              course: { category_id: '0',
                        category_attributes: { name: 'New Category', organization_id: pla.id } },
              commit: 'Save Course' }
          end

          it 'should create a new category in originating org' do
            expect do
              patch :update, params: new_category_params
            end.to change { pla.categories.count }.by(1)
          end

          it 'should not change category for child course' do
            expect do
              patch :update, params: new_category_params
            end.to_not(change { child_course.reload.category })
          end
        end
      end
    end

    context 'imported course' do
      before do
        @request.host = "#{org.subdomain}.test.host"
        sign_in admin
      end

      describe 'publish an imported course' do
        let(:new_category) { FactoryBot.create(:category, organization: org) }

        it 'should change the publication status' do
          expect do
            patch :update, params: { id: child_course.to_param, course: child_course.attributes, commit: 'Publish' }
          end.to change { child_course.reload.pub_status }.from('D').to('P')
        end

        it 'should not change title, if new title is given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { title: 'New Title' }, commit: 'Publish' }
          end.to_not(change { child_course.reload.title })
        end

        it 'should redirect to admin dashboard' do
          patch :update, params: { id: child_course.to_param, course: child_course.attributes, commit: 'Publish' }
          expect(response).to redirect_to(admin_dashboard_index_path)
        end

        it 'should change the course category, if given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { category_id: new_category.id }, commit: 'Publish' }
          end.to change { child_course.reload.category }.to(new_category)
        end

        it 'should change the course access level, if given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { access_level: 'authenticated_users' }, commit: 'Publish' }
          end.to change { child_course.reload.access_level }.from('everyone').to('authenticated_users')
        end
      end
    end
  end
end
