# frozen_string_literal: true

require 'csv'

module Admin
  class UsersController < BaseController
    before_action :enable_sidebar, except: [:index]

    skip_before_action :authorize_admin, only: :index
    before_action :authorize_admin_or_trainer, only: :index

    def index
      users = policy_scope(User).includes(profile: [:language])

      @users = if params[:users_search].blank?
                 users
               else
                 users.search_users(params[:users_search])
               end

      enable_sidebar
    end

    def change_user_roles
      user = User.find(params[:id])
      authorize user, :update?

      org = user.roles.find_by(resource_type: 'Organization').nil? ? current_organization : user.organization
      new_role = params[:value].downcase.to_sym

      user.roles = []
      user.add_role(new_role, org)

      if user.save
        render status: :ok, json: user.current_roles.to_s
      else
        render status: :unprocessable_entity, json: 'roles failed to update'
      end
    end

    def export_user_info
      @users = policy_scope(User)

      respond_to do |format|
        format.csv { send_data users_csv(@users), filename: "#{subdomain_name}_users_#{current_date_string}.csv" }
      end
    end

    private

    def users_csv(users)
      CSV.generate do |csv|
        csv << ['User Name', 'User Last Name', 'User Email', 'User Role', 'Preferred Language', 'Registration Date', 'Branch', 'Zip Code', 'Courses User has Started', 'Courses User has Completed']

        users.each do |user|
          row = []
          profile = user.profile

          row << profile.try(:first_name)
          row << profile.try(:last_name)
          row << user.email
          row << user.roles.map(&:name).map(&:capitalize).join(', ')
          row << user.preferred_language
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
      Time.zone.now.strftime('%m-%d-%Y')
    end
  end
end
