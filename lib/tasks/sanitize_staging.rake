# frozen_string_literal: true

namespace :staging do
  desc 'Sanitize DB: delete all non-admin users and their data'
  task sanitize: :environment do
    abort 'ABORT: This task must not run in production!' if Rails.env.production?

    puts '=== Staging DB Sanitize ==='
    puts "Environment: #{Rails.env}"
    puts ''

    # Find all users who have any admin role (org-scoped or global)
    admin_user_ids = User.joins(:roles).where(roles: { name: 'admin' }).distinct.pluck(:id)
    puts "Admin users to keep: #{admin_user_ids.size} (IDs: #{admin_user_ids.join(', ')})"

    non_admin_user_ids = User.where.not(id: admin_user_ids).pluck(:id)
    puts "Non-admin users to delete: #{non_admin_user_ids.size}"
    puts ''

    if non_admin_user_ids.empty?
      puts 'No non-admin users found, skipping user deletion.'
    else
      non_admin_user_ids.each_slice(1000) do |batch_ids|
        progress_ids = CourseProgress.where(user_id: batch_ids).pluck(:id)

        LessonCompletion.where(course_progress_id: progress_ids).delete_all unless progress_ids.empty?
        CourseProgress.where(id: progress_ids).delete_all unless progress_ids.empty?
        Profile.where(user_id: batch_ids).delete_all
        Doorkeeper::AccessToken.where(resource_owner_id: batch_ids).delete_all
        Doorkeeper::AccessGrant.where(resource_owner_id: batch_ids).delete_all

        # Rolify join table — no AR model, use raw SQL
        sanitized_ids = batch_ids.map(&:to_i).join(',')
        ActiveRecord::Base.connection.execute(
          "DELETE FROM users_roles WHERE user_id IN (#{sanitized_ids})"
        )

        User.where(id: batch_ids).delete_all
        print '.'
      end
      puts ''
      puts "Deleted #{non_admin_user_ids.size} non-admin users and all associated data."
    end

    User.where(id: admin_user_ids).update_all(
      reset_password_token: nil,
      reset_password_sent_at: nil,
      remember_created_at: nil,
      sign_in_count: 0,
      current_sign_in_at: nil,
      last_sign_in_at: nil,
      current_sign_in_ip: nil,
      last_sign_in_ip: nil
    )
    puts ''

    # Clear standalone tables with no user FK
    deleted_contacts = Contact.delete_all
    puts "Deleted #{deleted_contacts} contacts"

    puts ''
    puts '=== Done! Staging DB sanitized. ==='
    puts 'Admin accounts retained:'
    User.where(id: admin_user_ids).each do |u|
      puts "  #{u.email} (org: #{u.organization&.subdomain})"
    end
  end
end
