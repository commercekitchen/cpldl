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
#  sort_order      :integer          default(0)
#  custom          :boolean          default(FALSE)
#

require "rails_helper"

RSpec.describe LibraryLocation, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:zipcode) }

  it "should sort by sort order by default" do
    last_branch = FactoryBot.create(:library_location, sort_order: 10, created_at: 10.days.ago)
    first_branch = FactoryBot.create(:library_location, sort_order: 1, created_at: Time.zone.now)

    expect(described_class.all.first).to eq(first_branch)
    expect(described_class.all.last).to eq(last_branch)
  end
end
