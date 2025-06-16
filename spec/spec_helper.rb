require 'webmock/rspec'
require 'upwoof_listings'
require 'vcr'
include UpwoofListings::Resources

APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
cnf = YAML.load_file(File.join(APP_ROOT, 'config/gem_secret.yml'))
upwoof_listings_api_key = cnf['upwoof_listings_api_key']

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<UPWOOF_LISTINGS_API_KEY>') { upwoof_listings_api_key }
end

RSpec.configure do |config|
  config.before do
    UpwoofListings.api_key = upwoof_listings_api_key
  end
end
