require 'spec_helper'

describe UpwoofListings do
  describe '.url default' do
    # The spec_helper before hook overrides .url with the test config value,
    # so reload the library to restore the hardcoded default for this example.
    #
    # NOTE: `load`-ing a file that Coverage is already tracking resets that
    # file's line counts. Because RSpec loads this file last, that reset would
    # otherwise wipe the coverage other specs recorded for upwoof_listings.rb
    # (notably `.client`). The `.client` example below re-exercises it *after*
    # the reload so the final tally is accurate.
    before { load File.expand_path('../lib/upwoof_listings.rb', __dir__) }

    it 'points at the pethotels.upwoof.com host' do
      expect(UpwoofListings.url).to eq('https://pethotels.upwoof.com/api/v1/')
    end

    it 'still builds a memoized client after reload' do
      UpwoofListings.instance_variable_set(:@client, nil)
      client = UpwoofListings.client
      expect(client).to be_a(UpwoofListings::Client)
      expect(UpwoofListings.client).to be(client)
    end
  end
end
