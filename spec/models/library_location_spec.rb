require "rails_helper"

RSpec.describe LibraryLocation, type: :model do
  it { should belong_to(:organization) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:zipcode) }
end
