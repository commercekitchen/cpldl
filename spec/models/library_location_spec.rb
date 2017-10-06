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

  it "should sort alphabetically by default" do
    last_branch = FactoryGirl.create(:library_location, name: "Z branch", created_at: 10.days.ago)
    first_branch = FactoryGirl.create(:library_location, name: "A branch", created_at: Time.zone.now)

    expect(described_class.all.first).to eq(first_branch)
    expect(described_class.all.last).to eq(last_branch)
  end
end
