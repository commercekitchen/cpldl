# frozen_string_literal: true

require 'csv'

module Api
  module V1
    module Admin
      class UsersController < ::Api::V1::BaseController
        before_action :require_admin

        PER_PAGE = 25
        ALLOWED_ROLES = %w[user admin trainer].freeze

        def index
          users = filtered_users(params[:q])
          total = users.count('users.id')
          page  = [params.fetch(:page, 1).to_i, 1].max

          paginated = users
                        .order('users.created_at DESC')
                        .offset((page - 1) * PER_PAGE)
                        .limit(PER_PAGE)

          render json: {
            users: paginated.map { |u| user_payload(u) },
            meta: { total: total, page: page, perPage: PER_PAGE }
          }
        end

        def update_role
          user = current_organization.users.find(params[:id])
          authorize user, :update?

          new_role = params[:role].to_s.downcase
          unless ALLOWED_ROLES.include?(new_role)
            render status: :unprocessable_entity, json: { message: 'Invalid role.' }
            return
          end

          user.roles = []
          user.add_role(new_role.to_sym, current_organization)

          if user.save
            render json: { role: primary_role(user) }
          else
            render status: :unprocessable_entity, json: { errors: user.errors.full_messages }
          end
        end

        def export
          users = policy_scope(User)
                    .includes(:profile, :roles, course_progresses: [:course])
                    .order('users.created_at DESC')

          csv_data = users_csv(users)

          response.headers['Content-Type']        = 'text/csv; charset=utf-8'
          response.headers['Content-Disposition'] = "attachment; filename=\"#{export_filename}\""
          render body: csv_data
        end

        private

        def require_admin
          unless current_user&.admin?
            render status: :forbidden, json: { message: 'You are not authorized to perform this action.' }
          end
        end

        def filtered_users(q)
          base = policy_scope(User).includes(:profile, :roles)

          if q.present?
            term = "%#{ActiveRecord::Base.sanitize_sql_like(q)}%"
            base
              .joins('LEFT JOIN profiles ON profiles.user_id = users.id')
              .where(
                'users.email ILIKE :term OR profiles.first_name ILIKE :term OR profiles.last_name ILIKE :term',
                term: term
              )
              .distinct
          else
            base
          end
        end

        def user_payload(user)
          {
            id: user.id,
            firstName: user.first_name,
            lastName: user.last_name,
            email: user.email,
            role: primary_role(user),
            createdAt: user.created_at.strftime('%Y-%m-%d')
          }
        end

        def primary_role(user)
          return 'admin'   if user.admin?
          return 'trainer' if user.trainer?

          'user'
        end

        def users_csv(users)
          CSV.generate do |csv|
            csv << [
              'First Name', 'Last Name', 'Email', 'Role',
              'Preferred Language', 'Registration Date',
              'Branch', 'Zip Code',
              'Courses In Progress', 'Courses Completed'
            ]

            users.each do |user|
              profile = user.profile
              csv << [
                profile&.first_name,
                profile&.last_name,
                user.email,
                user.roles.map(&:name).map(&:capitalize).join(', '),
                user.preferred_language,
                user.created_at.in_time_zone('Central Time (US & Canada)').strftime('%m-%d-%Y'),
                profile&.library_location_name,
                profile&.try(:zip_code),
                user.course_progresses.select { |cp| cp.completed_at.nil? }.map { |cp| cp.course.title }.join(', '),
                user.course_progresses.reject { |cp| cp.completed_at.nil? }.map { |cp| cp.course.title }.join(', ')
              ]
            end
          end
        end

        def export_filename
          subdomain = current_organization.subdomain.to_s
          date      = Time.zone.now.strftime('%m-%d-%Y')
          "#{subdomain}_users_#{date}.csv"
        end
      end
    end
  end
end
