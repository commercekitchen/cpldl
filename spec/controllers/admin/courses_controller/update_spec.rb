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
        pla_course.attributes.merge('title' => 'Updated Title', 'access_level' => 'authenticated_users', 'category_id' => pla_category2.id, 'notes' => 'New Notes')
      end

      let(:new_topic_params) do
        update_params.merge(course_topics_attributes: [{ topic_attributes: { title: 'Another new topic' } }])
      end

      let(:save_request) do
        patch :update, params: { id: pla_course.to_param, course: update_params, commit: 'Save Course' }
      end

      it 'redirects to edit path' do
        save_request
        expect(response).to redirect_to(edit_admin_course_path(pla_course.reload))
      end

      it 'updates title' do
        expect do
          save_request
        end.to change { pla_course.reload.title }.from('PLA Course').to('Updated Title')
      end

      it 'updates access level' do
        expect do
          save_request
        end.to change { pla_course.reload.access_level }.from('everyone').to('authenticated_users')
      end

      it 'updates category' do
        expect do
          save_request
        end.to change { pla_course.reload.category }.from(pla_category1).to(pla_category2)
      end

      it 'displays appropriate notice for successful course update' do
        save_request
        expect(flash[:notice]).to eq('Course was successfully updated.')
      end

      it 'redirects to lesson edit page if desired' do
        patch :update, params: { id: pla_course.to_param, course: update_params, commit: 'Save & Edit Lessons' }
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
            save_request
          end.to change { child_course.reload.title }.to('Updated Title')
        end

        it 'propagates topic to child courses' do
          expect do
            patch :update, params: { id: pla_course.to_param, course: new_topic_params }
          end.to(change { child_course.reload.topics })
        end

        it 'does not assign course to main site category' do
          expect do
            save_request
          end.to_not(change { child_course.reload.category })
        end

        it 'does not change child course access level' do
          expect do
            save_request
          end.to_not(change { child_course.reload.access_level })
        end

        it 'does not propagate notes/content for further learning to child courses' do
          expect do
            save_request
          end.to_not(change { child_course.reload.notes })
        end

        describe 'attachments' do
          let(:document) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf') }

          let(:attachment_attributes) do
            { attachments_attributes: {
              '0' => {
                document: document,
                title: '',
                doc_type: 'additional-resource',
                file_description: 'additional-resource attachment test'
              }
            } }
          end

          it 'adds attachments to parent course' do
            expect do
              patch :update, params: { id: pla_course.to_param, course: attachment_attributes }
            end.to change { pla_course.attachments.count }.by(1)
          end

          it 'does not propagate attachments to child course' do
            expect do
              patch :update, params: { id: pla_course.to_param, course: attachment_attributes }
            end.to_not(change { child_course.attachments.count })
          end
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

      describe 'save an imported course' do
        let(:new_category) { FactoryBot.create(:category, organization: org) }
        let(:document) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf') }

        let(:additional_resource_attachment_attributes) do
          { '0' => {
            document: document,
              title: '',
              doc_type: 'additional-resource',
              file_description: 'additional-resource attachment test'
          } }
        end

        let(:text_copy_attachment_attributes) do
          { '0' => {
            document: document,
            title: '',
            doc_type: 'text-copy',
            file_description: 'text-copy attachment test'
          } }
        end

        it 'should not change title, if new title is given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { title: 'New Title' }, commit: 'Save Course' }
          end.to_not(change { child_course.reload.title })
        end

        it 'should redirect to course edit page' do
          patch :update, params: { id: child_course.to_param, course: child_course.attributes, commit: 'Save Course' }
          expect(response).to redirect_to(edit_admin_course_path(child_course))
        end

        it 'should change the course category, if given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { category_id: new_category.id }, commit: 'Save Course' }
          end.to change { child_course.reload.category }.to(new_category)
        end

        it 'should change the course access level, if given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { access_level: 'authenticated_users' }, commit: 'Save Course' }
          end.to change { child_course.reload.access_level }.from('everyone').to('authenticated_users')
        end

        it 'should change publication status, if given' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { pub_status: 'P' }, commit: 'Save Course' }
          end.to change { child_course.reload.pub_status }.from('D').to('P')
        end

        it 'should add an additional resource attachment' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { attachments_attributes: additional_resource_attachment_attributes } }
          end.to change { child_course.reload.attachments.count }.by(1)
        end

        it 'should update course notes' do
          expect do
            patch :update, params: { id: child_course.to_param, course: { notes: 'new course notes' } }
          end.to change { child_course.reload.notes }.from(nil).to('new course notes')
        end
      end
    end
  end
end
