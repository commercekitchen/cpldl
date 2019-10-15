# frozen_string_literal: true

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

require 'rails_helper'

describe Profile do

  context 'verify validations' do

    before(:each) do
      @profile = FactoryBot.create(:profile)
    end

    it 'initially it is valid' do
      expect(@profile).to be_valid
    end

    it 'validates the zip code, if present' do
      @profile.zip_code = '80210'
      expect(@profile).to be_valid

      @profile.zip_code = '80210-1234'
      expect(@profile).to be_valid

      @profile.zip_code = ''
      expect(@profile).to be_valid

      @profile.zip_code = '123'
      expect(@profile).to_not be_valid

      @profile.zip_code = '123-123123'
      expect(@profile).to_not be_valid
    end

  end

  context 'delgated metods' do
    describe 'no library_location' do
      let(:profile) { FactoryBot.create(:profile) }

      it 'should return nil for location name' do
        expect(profile.library_location_name).to be_nil
      end

      it 'should return nil for location zipcode' do
        expect(profile.library_location_zipcode).to be_nil
      end
    end

    describe 'with library_location' do
      let(:library_location) { FactoryBot.create(:library_location) }
      let(:profile) { FactoryBot.create(:profile, library_location: library_location) }

      it 'should return correct location name' do
        expect(profile.library_location_name).to eq(library_location.name)
      end

      it 'should return correct zipcode' do
        expect(profile.library_location_zipcode).to eq(library_location.zipcode)
      end
    end
  end

  context 'public methods' do

    describe 'program_organization' do
      before do
        @npl = FactoryBot.create(:organization, :accepts_programs, subdomain: 'npl')
        @profile = FactoryBot.build(:profile, :with_last_name)
        @user = FactoryBot.create(:user, profile: @profile, organization: @npl)
      end

      it 'should return true for organization with programs' do
        expect(@profile.program_organization).to be true
      end

      it "should return false if organization doesn't accept programs" do
        @npl.update(accepts_programs: false)
        expect(@profile.program_organization).to be false
      end
    end

    describe 'full_name' do
      before do
        @profile = FactoryBot.create(:profile)
      end

      it 'displays first name if no last name' do
        expect(@profile.full_name).to eq @profile.first_name
      end

      it 'displays full name if last name' do
        @profile.update(last_name: 'last_name')
        expect(@profile.full_name).to eq "#{@profile.first_name} #{@profile.last_name}"
      end
    end

    describe 'context_update' do

      before(:each) do
        @profile = FactoryBot.create(:profile)
        @user = @profile.user
      end

      context 'user in organization without programs' do
        it 'should update profile without last name' do
          old_first_name = @profile.first_name
          @profile.context_update(
            {
              first_name: "#{old_first_name}_new"
            }
          )
          @profile.reload
          expect(@profile.first_name).to eq "#{old_first_name}_new"
        end
      end

      context 'user in organization with programs' do

        before do
          @new_org = FactoryBot.create(:organization, :accepts_programs, subdomain: 'new')
          @user.update(organization: @new_org)
        end

        it 'should not update profile without last name' do
          old_first_name = @profile.first_name
          @profile.context_update(
            {
              first_name: "#{old_first_name}_new"
            }
          )
          @profile.reload
          expect(@profile.first_name).to eq "#{old_first_name}"
        end

        it 'should update profile with last name' do
          old_first_name = @profile.first_name
          @profile.context_update(
            {
              first_name: "#{old_first_name}_new",
              last_name: 'new_last_name'
            }
          )
          @profile.reload
          expect(@profile.first_name).to eq "#{old_first_name}_new"
          expect(@profile.last_name).to eq 'new_last_name'
        end
      end
    end
  end

end
