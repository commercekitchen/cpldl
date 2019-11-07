# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                            :integer          not null, primary key
#  email                         :string           default("")
#  encrypted_password            :string           default(""), not null
#  reset_password_token          :string
#  reset_password_sent_at        :datetime
#  remember_created_at           :datetime
#  sign_in_count                 :integer          default(0), not null
#  current_sign_in_at            :datetime
#  last_sign_in_at               :datetime
#  current_sign_in_ip            :string
#  last_sign_in_ip               :string
#  confirmation_token            :string
#  confirmed_at                  :datetime
#  confirmation_sent_at          :datetime
#  unconfirmed_email             :string
#  failed_attempts               :integer          default(0), not null
#  unlock_token                  :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  profile_id                    :integer
#  quiz_modal_complete           :boolean          default(FALSE)
#  invitation_token              :string
#  invitation_created_at         :datetime
#  invitation_sent_at            :datetime
#  invitation_accepted_at        :datetime
#  invitation_limit              :integer
#  invited_by_id                 :integer
#  invited_by_type               :string
#  invitations_count             :integer          default(0)
#  token                         :string
#  organization_id               :integer
#  school_id                     :integer
#  program_location_id           :integer
#  acting_as                     :string
#  library_card_number           :string
#  student_id                    :string
#  date_of_birth                 :datetime
#  grade                         :integer
#  quiz_responses_object         :text
#  program_id                    :integer
#  encrypted_library_card_pin    :string
#  encrypted_library_card_pin_iv :string
#

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "jane#{n}@example.com" }
    password 'abcd1234'
    sign_in_count 2
    organization
    profile { build(:profile, user: nil) }

    after(:create) do |user|
      user.add_role(:user, user.organization)
    end

    trait :library_card_login_user do
      email { nil }
      library_card_number { Array.new(7) { rand(10) }.join }
      library_card_pin { Array.new(4) { rand(10) }.join }

      before(:create) do |user|
        user.password = Digest::MD5.hexdigest(user.library_card_pin).first(10)
      end
    end

    trait :first_time_user do
      sign_in_count 0
    end

    trait :admin do
      after(:create) do |user|
        user.roles.destroy_all
        user.add_role(:admin, user.organization)
      end
    end
  end
end
