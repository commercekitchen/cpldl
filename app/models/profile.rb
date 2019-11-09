# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  belongs_to :language, optional: true
  belongs_to :library_location, optional: true

  validates :first_name, presence: true
  validates :last_name, presence: true, if: :program_organization
  validates :zip_code, format: { with: /\A\d{5}-\d{4}|\A\d{5}\z/, message: 'should be ##### or #####-####' },
    allow_blank: true

  accepts_nested_attributes_for :library_location

  delegate :name, :zipcode, to: :library_location, prefix: true, allow_nil: true

  def context_update(attributes)
    with_transaction_returning_status do
      assign_attributes(attributes)
      save(context: :profile_update)
    end
  end

  def program_organization
    user.organization.accepts_programs?
  end

  def full_name
    if last_name.present?
      "#{first_name} #{last_name}"
    else
      first_name
    end
  end
end
