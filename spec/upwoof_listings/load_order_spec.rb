require 'spec_helper'
# Required explicitly rather than relied on transitively — which is the whole point of this file.
require 'English'
require 'shellwords'

# These run the library in a fresh process rather than in this one.
#
# The suite loads everything, so a missing require is invisible here: some other spec has already
# pulled in the file that happened to carry it. That is exactly how the resource layer came to
# depend on ActiveSupport being required by client.rb — reaching Resources::Object.parse without
# first building a client raised NoMethodError on deep_transform_keys, and only ever showed up
# when a single spec file was run on its own.
describe 'loading the library' do
  def lib_path
    File.expand_path('../../lib', __dir__)
  end

  # @return [Array(String, Boolean)] the child's output, and whether it exited cleanly.
  def in_clean_process(source)
    command = [RbConfig.ruby, '-I', lib_path, '-e', source].shelljoin
    [`#{command} 2>&1`, $CHILD_STATUS.success?]
  end

  # Each of these is a plausible first require for a caller who wants one part of the gem.
  %w[
    upwoof_listings
    upwoof_listings/client
    upwoof_listings/dsl
    upwoof_listings/errors
    upwoof_listings/resources
    upwoof_listings/utils
  ].each do |entry_point|
    it "requires #{entry_point} on its own" do
      output, ok = in_clean_process("require '#{entry_point}'; print 'loaded'")

      expect(output).to eq('loaded')
      expect(ok).to be(true)
    end
  end

  it 'parses a response without a client having been built' do
    output, ok = in_clean_process(<<~RUBY)
      require 'upwoof_listings/resources'
      require 'json'

      response = Struct.new(:body).new({ 'Name' => 'Rex' }.to_json)
      def response.blank? = false

      print UpwoofListings::Resources::Object.parse(response)['name']
    RUBY

    expect(output).to eq('Rex')
    expect(ok).to be(true)
  end

  it 'builds a URL without a client having been built' do
    output, ok = in_clean_process(<<~RUBY)
      require 'upwoof_listings/utils'

      print UpwoofListings::Utils::UrlHelper.build_url(path: 'https://x.test/a', params: { page: 2 })
    RUBY

    expect(output).to eq('https://x.test/a?page=2')
    expect(ok).to be(true)
  end

  it 'validates a blank id without a client having been built' do
    output, ok = in_clean_process(<<~RUBY)
      require 'upwoof_listings/dsl'

      caller_class = Class.new { include UpwoofListings::DSL }
      begin
        caller_class.new.get_listing(id: nil)
      rescue ArgumentError => e
        print e.message
      end
    RUBY

    expect(output).to eq('ID cannot be blank')
    expect(ok).to be(true)
  end
end
