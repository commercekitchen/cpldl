# frozen_string_literal: true

require 'rails_helper'

describe Admin::ReportExportsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:csv) { file_fixture('example_report.csv') }

  before do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in user
  end

  describe 'report types' do
    [
      { report_param: 'registrations', exporter_class: RegistrationExporter },
      { report_param: 'completed_courses', exporter_class: CompletedCoursesExporter },
      { report_param: 'incomplete_courses', exporter_class: UnfinishedCoursesExporter },
      { report_param: 'no_courses', exporter_class: NoCoursesReportExporter },
      { report_param: 'completed_lessons', exporter_class: CompletedLessonsExporter }
    ].each do |report_type|
      it "should have a successful response for #{report_type[:report_param]}" do
        get :show, params: { report: report_type[:report_param] }, format: :csv
        expect(response).to have_http_status(:ok)
      end

      it "should respond with csv header for #{report_type[:report_param]}" do
        get :show, params: { report: report_type[:report_param] }, format: :csv
        expect(response.content_type).to eq('text/csv')
      end

      it "should respond with csv header for #{report_type[:report_param]}" do
        get :show, params: { report: report_type[:report_param] }, format: :csv
        expect(response.headers['Content-Disposition']).to include("#{report_type[:report_param]}.csv")
      end

      it "should call correct exporter for #{report_type[:report_param]}" do
        exporter = instance_double(report_type[:exporter_class], to_csv: csv)
        expect(report_type[:exporter_class]).to receive(:new).with(organization).and_return(exporter)
        get :show, params: { report: report_type[:report_param] }, format: :csv
      end
    end
  end
end
