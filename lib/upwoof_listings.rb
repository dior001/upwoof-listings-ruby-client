# Required at the entry point rather than in the client, because the DSL, the utils and the
# resources all lean on these too and are perfectly usable without a client ever being built.
# Requiring them only in client.rb left `Resources::Object.parse` raising NoMethodError on
# deep_transform_keys for anyone who reached the resource layer first.
#
# The three features the gem actually uses, rather than active_support/all: `blank?` and
# `present?`, `to_query` for building query strings, and `deep_transform_keys` for downcasing
# response keys.
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/hash/keys'

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
    attr_accessor :url, :logger
  end

  self.url = 'https://pethotels.upwoof.com/api/v1/'

  module_function

  # @return [UpwoofListings::Client]
  def client
    @client ||= Client.new(UpwoofListings.api_key, UpwoofListings.url)
  end
end
