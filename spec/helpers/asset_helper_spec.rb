require 'rails_helper'

describe AssetHelper do
  describe '#asset_with_extension' do
    it 'should return correct asset path from name with no extension' do
      expect(helper.asset_with_extension('dl_logo')).to eq('dl_logo.png')
    end

    it 'should not append additional extension to path' do
      expect(helper.asset_with_extension('dl_logo.png')).to eq('dl_logo.png')
    end
  end
end
