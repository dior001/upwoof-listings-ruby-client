require 'faraday'
require 'faraday/multipart'
require 'json'
require 'openssl'
require 'upwoof_listings'
require 'upwoof_listings/dsl'
require 'upwoof_listings/errors'
require 'upwoof_listings/utils'

module UpwoofListings
  class Client
    include DSL
    include Errors
    include Utils

    REQUESTS = %i[get post put patch delete]
    # The API caps a page at 100 records (a larger per_page answers 100), so never ask for more.
    MAX_PER_PAGE = 100
    HEADERS = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }

    def initialize(api_key = UpwoofListings.api_key, url = UpwoofListings.url)
      @api_key = api_key
      @url = url

      # Setup HTTP request connection to UpWoof.
      @connection ||= Faraday.new do |builder|
        builder.request :multipart
        builder.request :url_encoded
        builder.response :logger
        builder.adapter Faraday.default_adapter
      end
    end

    # @param [:get, :post, :put, :patch, :delete] method.
    # @param [String] path.
    # @param [Hash] query (optional).
    # @param [Hash] headers request headers (optional).
    # @raise [ArgumentError] If the response is blank.
    # @raise [ResourceNotFoundError] If the response code is 404.
    # @raise [ValidationError] If the response code is 422 (the API's messages are in #errors).
    # @raise [ClientError] If the response code is not in the success range.
    # @return [Faraday::Response] server response.
    def request(method, path, query = {}, headers = HEADERS)
      unless REQUESTS.include?(method)
        raise ArgumentError,
              "Unsupported method #{method.inspect}. Only :get, :post, :put, :patch, :delete are allowed"
      end

      params = { access_token: @api_key }
      params.merge!(clamp_per_page(query)) if method == :get && query.is_a?(Hash)
      token_url = UrlHelper.build_url(path: "#{@url}#{path}", params: params)
      payload = nil
      if query.present? && method != :get
        accept = headers.present? ? headers['Accept'] : nil
        payload = if accept.present? && accept == 'application/json'
                    JSON.generate(query)
                  else
                    query
                  end
      end
      response = @connection.run_request(method, token_url, payload, headers)

      case response.status.to_i
      when 200..299
        response
      when 404
        raise ResourceNotFoundError.new(response: response)
      when 422
        raise ValidationError.new(response: response)
      else
        raise ClientError.new(response: response)
      end
    end

    private

    def clamp_per_page(query)
      key = [:per_page, 'per_page'].find { |candidate| query.key?(candidate) }
      return query if key.nil?

      requested = Integer(query[key].to_s, exception: false)
      return query if requested.nil?

      query.merge(key => [requested, MAX_PER_PAGE].min)
    end
  end
end
