# frozen_string_literal: true

require 'csv'

module Admin
  class UsersController < BaseController
    def change_user_roles
      user     = User.find(params[:id])
      org      = user.roles.find_by_resource_type('Organization').nil? ? current_organization : user.organization
      new_role = params[:value].downcase.to_sym

      user.roles = []
      user.add_role(new_role, org)

      if user.save
        render status: 200, json: user.current_roles.to_s
      else
        render status: :unprocessable_entity, json: 'roles failed to update'
      end
    end

    def export_user_info
      @users = User.where(organization_id: current_organization.id)

      respond_to do |format|
        format.csv { send_data users_csv(@users), filename: "#{subdomain_name}_users_#{current_date_string}.csv" }
      end
    end

    private

    def users_csv(users)
      CSV.generate do |csv|
        attributes = []
        csv << ['User Name', 'User Last Name', 'User Email', 'User Role', 'Registration Date', 'Branch', 'Zip Code', 'Courses User has Started', 'Courses User has Completed']

        users.each do |user|
          row = []
          profile = user.profile

          row << profile.try(:first_name)
          row << profile.try(:last_name)
          row << user.email
          row << user.roles.map(&:name).map(&:capitalize).join(', ')
          row << user.created_at.in_time_zone('Central Time (US & Canada)').strftime('%m-%d-%Y')
          row << profile.try(:library_location).try(:name)
          row << profile.try(:zip_code)
          row << user.course_progresses.where(completed_at: nil).map { |cp| cp.course.title }.join(', ')
          row << user.course_progresses.where.not(completed_at: nil).map { |cp| cp.course.title }.join(', ')

          csv << row
        end
      end
    end

    def subdomain_name
      current_organization.try(:subdomain)
    end

    def current_date_string
      Date.today.strftime('%m-%d-%Y')
    end
  end
end
