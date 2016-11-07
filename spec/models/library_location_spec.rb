# == Schema Information
#
# Table name: library_locations
#
#  id              :integer          not null, primary key
#  name            :string
#  zipcode         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#

require "rails_helper"

RSpec.describe LibraryLocation, type: :model do
  it { should belong_to(:organization) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:zipcode) }
end
