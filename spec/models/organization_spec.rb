# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  subdomain  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

RSpec.describe Organization, type: :model do
  before do
    @org = create(:organization)
    other_org = create(:organization, subdomain: "www")
    @user1 = create(:user, organization: @org)
    @user1.add_role("admin", @org)

    @user2 = create(:user, organization: @org)
    @user2.add_role("admin", @org)

    @user3 = create(:user, organization: @org)
    @user3.add_role("user", @org)

    @user4 = create(:user, organization: other_org)
    @user4.add_role("user", other_org)
  end

  it { should have_many(:cms_pages) }
  it { should have_many(:library_locations) }

  describe "#users_count" do
    it "returns the count of its users" do
      expect(@org.user_count).to eq(3)
    end
  end

  describe "#admin_user_emails" do
    it "returns emails of the admins" do
      expect(@org.admin_user_emails).to include(@user1.email)
      expect(@org.admin_user_emails).to include(@user2.email)
      expect(@org.admin_user_emails).not_to include(@user3.email)
      expect(@org.admin_user_emails).not_to include(@user4.email)
    end
  end
end
