# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  first_name  :string
#  zip_code    :string
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer
#

require "rails_helper"

describe Profile do

  context "verify validations" do

    before(:each) do
      @profile = FactoryGirl.create(:profile)
    end

    it "initially it is valid" do
      expect(@profile).to be_valid
    end

    it "validates the zip code, if present" do
      @profile.zip_code = "80210"
      expect(@profile).to be_valid

      @profile.zip_code = "80210-1234"
      expect(@profile).to be_valid

      @profile.zip_code = ""
      expect(@profile).to be_valid

      @profile.zip_code = "123"
      expect(@profile).to_not be_valid

      @profile.zip_code = "123-123123"
      expect(@profile).to_not be_valid
    end

  end

end
