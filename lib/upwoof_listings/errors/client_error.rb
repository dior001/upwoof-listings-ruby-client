require 'json'

module UpwoofListings
  module Errors
    class ClientError < StandardError
      attr_reader :response, :errors

      def initialize(response:)
        @response = response
        @errors = self.class.errors_from(response)
        super("HTTP #{response.status}: #{response.body}")
      end

      # The `errors` list from an API error body (`{"errors": [...]}`), else an empty array.
      # @return [Array]
      def self.errors_from(response)
        body = JSON.parse(response.body.to_s)
        return [] unless body.is_a?(Hash) && !body['errors'].nil?

        Array(body['errors'])
      rescue JSON::ParserError
        []
      end
    end
  end
end
