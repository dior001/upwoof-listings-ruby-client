require 'json'

module UpwoofListings
  module Errors
    class ClientError < StandardError
      attr_reader :response, :body, :errors

      def initialize(response:)
        @response = response
        @body = self.class.body_from(response)
        @errors = self.class.errors_from(response)
        super("HTTP #{response.status}: #{response.body}")
      end

      # The parsed JSON error body, or nil when there is none.
      # @return [Hash, Array, nil]
      def self.body_from(response)
        JSON.parse(response.body.to_s)
      rescue JSON::ParserError
        nil
      end

      # The API's messages from an error body: its `errors` list (a hash of messages keyed by field gives its
      # values), else its single `message` (`{"error": ..., "message": ...}`), else an empty array.
      # @return [Array]
      def self.errors_from(response)
        body = body_from(response)
        return [] unless body.is_a?(Hash)

        found = body['errors']
        return Array(body['message'].presence) if found.nil?

        found.is_a?(Hash) ? found.values : Array(found)
      end
    end
  end
end
