# frozen_string_literal: true

require 'rails_helper'

describe Admin::ReportExportsController do
  let(:organization) { FactoryBot.create(:organization) }
  let(:user) { FactoryBot.create(:user, :admin, organization: organization) }
  let(:csv) { file_fixture('example_report.csv') }
  let(:csv_lines) { csv.read.split("\n") }
  let(:default_start) { 1.month.ago.beginning_of_month }
  let(:default_end) { 1.month.ago.end_of_month }

  before do
    @request.host = "#{organization.subdomain}.test.host"
    sign_in user
  end

  it 'redirects if end_date is before start_date' do
    get :show, params: { report: 'registrations', start_date: '2025-03-01', end_date: '2025-01-01' }, format: :csv
    expect(response).to redirect_to admin_reports_path(start_date: '2025-03-01', end_date: '2025-01-01')
  end

  it 'uses default start_date and end_date if not provided' do
    exporter = instance_double(Exporters::RegistrationExporter, stream_csv: csv_lines.each)
    expect(Exporters::RegistrationExporter).to receive(:new).with(organization, start_date: default_start, end_date: default_end).and_return(exporter)
    get :show, params: { report: 'registrations' }, format: :csv
    expect(response).to have_http_status(:ok)
  end

  describe 'report types' do
    let(:start_date) { '2025-01-01' }
    let(:end_date) { '2025-03-01' }

    [
      { report_param: 'registrations', exporter_class: Exporters::RegistrationExporter },
      { report_param: 'completed_courses', exporter_class: Exporters::CompletedCoursesExporter },
      { report_param: 'incomplete_courses', exporter_class: Exporters::UnfinishedCoursesExporter },
      { report_param: 'no_courses', exporter_class: Exporters::NoCoursesReportExporter },
      { report_param: 'completed_lessons', exporter_class: Exporters::CompletedLessonsExporter }
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
        expected_filename = "#{organization.subdomain}-#{report_type[:report_param]}-#{default_start.strftime('%Y-%m-%d')}-#{default_end.strftime('%Y-%m-%d')}.csv"
        expect(response.headers['Content-Disposition']).to include(expected_filename)
      end

      it "should call correct exporter for #{report_type[:report_param]}" do
        exporter = instance_double(report_type[:exporter_class], stream_csv: csv_lines.each)
        expect(report_type[:exporter_class]).to receive(:new).with(organization, start_date: Date.parse(start_date), end_date: Date.parse(end_date)).and_return(exporter)
        get :show, params: { report: report_type[:report_param], start_date: start_date, end_date: end_date }, format: :csv
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'completion reports' do
      it 'calls completion report service with group_by zip_code' do
        expect_any_instance_of(CompletionReportService).to receive(:generate_completion_report).with(group_by: 'zip_code', start_date: default_start, end_date: default_end)
        get :show, params: { report: 'completions_by_zip_code', format: 'csv', group_by: 'zip_code' }
      end

      it 'calls completion report service with group_by partner' do
        expect_any_instance_of(CompletionReportService).to receive(:generate_completion_report).with(group_by: 'partner', start_date: default_start, end_date: default_end)
        get :show, params: { report: 'completions_by_partner', format: 'csv', group_by: 'partner' }
      end
    end
  end
end
