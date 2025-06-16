require 'upwoof_listings/version'

module UpwoofListings
  autoload :Client, 'upwoof_listings/client'
  autoload :DSL, 'upwoof_listings/dsl'
  autoload :Resources, 'upwoof_listings/resources'
  autoload :Errors, 'upwoof_listings/errors'
  autoload :Utils, 'upwoof_listings/utils'

  class << self
    # @return [String]
    attr_accessor :api_key
    attr_accessor :url
    attr_accessor :logger
  end

  self.url = 'https://www.upwoof.com/api/v1/'

  module_function

  # @return [UpwoofListings::Client]
  def client
    @client ||= Client.new(UpwoofListings.api_key, UpwoofListings.url)
  end
end
