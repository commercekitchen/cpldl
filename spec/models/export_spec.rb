# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  first_name          :string
#  zip_code            :string
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  language_id         :integer
#  library_location_id :integer
#

require "rails_helper"

describe Export do
  let(:library) { FactoryGirl.create(:library_location) }
  let(:data) { { :version => "lib", library.id => { :sign_ups => 1, :completions => { "Sample Course 3" => 1 } } } }

  context "check library name lookup" do
    let(:csv) { Export.to_csv_for_completion_report(data) }
    # #{:version=>"lib", 1=>{:sign_ups=>1, :completions=>{"Course 1"=>0}}}
    it "looks up the library name" do
      expect( csv).to match(/^Back of the Yards/)
      # expect(csv.row.first).to eq({"Bezazian"=>{:sign_ups=>1, :completions=>{"Course 1"=>0}})

    end

    # it "handles blank library names " do
    #   data = {}
    #   csv = Export.to_csv_for_completion_report(data)
    #   expect(csv.row.first).to eq 'Unknown'
    # end


  end

end
