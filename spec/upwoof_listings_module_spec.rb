require 'spec_helper'

describe UpwoofListings do
  it 'exposes the gem version' do
    # version.rb is required by the gemspec, so it is already loaded before
    # SimpleCov starts. Re-load it under coverage so its constant assignment is
    # actually exercised by the suite rather than counted as a pre-load.
    original_verbose = $VERBOSE
    $VERBOSE = nil # silence the "already initialized constant" warning
    load File.expand_path('../lib/upwoof_listings/version.rb', __dir__)
    $VERBOSE = original_verbose

    expect(UpwoofListings::VERSION).to eq('0.0.1')
  end

  it 'reads and writes the api_key accessor' do
    described_class.api_key = 'abc123'
    expect(described_class.api_key).to eq('abc123')
  end

  it 'reads and writes the url accessor' do
    original = described_class.url
    described_class.url = 'https://example.test/api/'
    expect(described_class.url).to eq('https://example.test/api/')
  ensure
    described_class.url = original
  end

  describe '.client' do
    before { described_class.instance_variable_set(:@client, nil) }

    it 'builds a memoized Client' do
      client = described_class.client
      expect(client).to be_a(UpwoofListings::Client)
      expect(described_class.client).to be(client)
    end
  end
end
