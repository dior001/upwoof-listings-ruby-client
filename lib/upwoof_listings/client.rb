require 'faraday'
require 'json'
require 'openssl'
require 'active_support/all'
require 'upwoof_listings/dsl'
require 'upwoof_listings/errors'
require 'upwoof_listings/utils'

module UpwoofListings
  class Client
    include DSL
    include Errors
    include Utils

    URL = 'https://www.upwoof.com/api/v1/'
    REQUESTS = %i[get post put delete]
    HEADERS = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

    def initialize
      # Setup HTTP request connection to Zenodo.
      @connection ||= Faraday.new do |builder|
        builder.request :multipart
        builder.request :url_encoded
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end

    # @param [:get, :post, :put, :delete] method.
    # @param [String] path.
    # @param [Hash] query (optional).
    # @param [Hash] headers request headers (optional).
    # @raise [ArgumentError] If the response is blank.
    # @raise [ResourceNotFoundError] If the response code is 404.
    # @raise [ClientError] If the response code is not in the success range.
    # @return [Faraday::Response] server response.
    def request(method, path, query = {}, headers = HEADERS)
      unless REQUESTS.include?(method)
        raise ArgumentError,
              "Unsupported method #{method.inspect}. Only :get, :post, :put, :delete are allowed"
      end

      payload = nil
      if query.present?
        accept = headers.present? ? headers['Accept'] : nil
        payload = if accept.present? && accept == 'application/json'
                    JSON.generate(query)
                  else
                    query
                  end
      end
      response = @connection.run_request(method, "#{URL}#{path}", payload, headers)

      case response.status.to_i
      when 200..299
        response
      when 404
        raise ResourceNotFoundError.new(response: response)
      else
        raise ClientError.new(response: response)
      end
    end
  end
end
