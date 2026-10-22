# frozen_string_literal: true

# Single source of truth for which admin reports exist, which organizations
# they apply to, which org roles may run them, and how each one is generated.
# Used both to list reports in the SPA and to authorize and build the export.
class ReportCatalog
  Report = Struct.new(:key, :title, :roles, :condition, :exporter, :completion_group, keyword_init: true) do
    def applies_to?(organization)
      condition.nil? || condition.call(organization)
    end

    def permitted_for?(user, organization)
      return false unless user && user.organization == organization

      roles.any? { |role| user.has_role?(role, organization) }
    end

    # Streamed reports are row-by-row exporters; the rest are aggregate
    # completion reports that CompletionReportService builds in one pass.
    def streamable?
      exporter.present?
    end

    # Returns an Enumerator of CSV lines for streamable reports, or the full
    # CSV string otherwise.
    def generate(organization, start_date:, end_date:)
      if streamable?
        exporter.new(organization, start_date: start_date, end_date: end_date).stream_csv
      else
        CompletionReportService.new(organization: organization)
                               .generate_completion_report(group_by: completion_group, start_date: start_date, end_date: end_date)
      end
    end
  end

  ADMIN_AND_TRAINER = %i[admin trainer].freeze

  REPORTS = [
    Report.new(key: 'completions_by_library', title: 'Completions Report (by Library)',
               roles: ADMIN_AND_TRAINER, condition: ->(org) { org.branches? }, completion_group: 'library'),
    Report.new(key: 'completions_by_zip_code', title: 'Completions Report (by Zip Code)',
               roles: ADMIN_AND_TRAINER, condition: ->(org) { org.branches? }, completion_group: 'zip_code'),
    Report.new(key: 'completions_by_partner', title: 'Completions Report (by Partner)',
               roles: ADMIN_AND_TRAINER, condition: ->(org) { org.accepts_partners? }, completion_group: 'partner'),
    Report.new(key: 'completions_by_survey_responses', title: 'Completions Report (by Survey Answers)',
               roles: ADMIN_AND_TRAINER, completion_group: 'survey_responses'),
    Report.new(key: 'incomplete_courses', title: 'Incomplete Courses',
               roles: ADMIN_AND_TRAINER, exporter: Exporters::UnfinishedCoursesExporter),
    Report.new(key: 'completed_courses', title: 'Completed Courses',
               roles: ADMIN_AND_TRAINER, exporter: Exporters::CompletedCoursesExporter),
    Report.new(key: 'completed_lessons', title: 'Completed Lessons',
               roles: ADMIN_AND_TRAINER, exporter: Exporters::CompletedLessonsExporter),
    Report.new(key: 'no_courses', title: 'Users that have not started a course',
               roles: ADMIN_AND_TRAINER, exporter: Exporters::NoCoursesReportExporter),
    Report.new(key: 'registrations', title: 'All Registrations',
               roles: ADMIN_AND_TRAINER, exporter: Exporters::RegistrationExporter)
  ].freeze

  def self.available_for(user, organization)
    REPORTS.select { |report| report.applies_to?(organization) && report.permitted_for?(user, organization) }
  end

  # Returns the report only if it exists, applies to the organization, and the
  # user's role may run it; nil otherwise. Never trust a report key from
  # params without going through this.
  def self.find_permitted(key, user, organization)
    available_for(user, organization).find { |report| report.key == key }
  end
end
