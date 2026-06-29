require 'spec_helper'

describe UpwoofListings do
  describe '.url default' do
    # The spec_helper before hook overrides .url with the test config value,
    # so reload the library to restore the hardcoded default for this example.
    before { load File.expand_path('../lib/upwoof_listings.rb', __dir__) }

    it 'points at the pethotels.upwoof.com host' do
      expect(UpwoofListings.url).to eq('https://pethotels.upwoof.com/api/v1/')
    end
  end
end
