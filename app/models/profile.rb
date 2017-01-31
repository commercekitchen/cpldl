# == Schema Information
#
# Table name: profiles
#
#  id                         :integer          not null, primary key
#  first_name                 :string
#  zip_code                   :string
#  user_id                    :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  language_id                :integer
#  library_location_id        :integer
#  last_name                  :string
#  phone                      :string
#  street_address             :string
#  city                       :string
#  state                      :string
#  opt_out_of_recommendations :boolean          default(FALSE)
#

class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :language
  belongs_to :library_location

  validates :first_name, presence: true
  validates :last_name, presence: true, if: :program_organization
  validates :zip_code, format: { with: /\A\d{5}-\d{4}|\A\d{5}\z/, message: "should be ##### or #####-####" },
    allow_blank: true

  def context_update(attributes)
    with_transaction_returning_status do
      assign_attributes(attributes)
      save(context: :profile_update)
    end
  end

  def program_organization
    if user.present?
      user.organization.accepts_programs?
    end
  end

  def full_name
    if last_name.present?
      "#{first_name} #{last_name}"
    else
      first_name
    end
  end
end
