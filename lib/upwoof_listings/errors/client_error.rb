module UpwoofListings
  module Errors
    class ClientError < StandardError
      attr_reader :response

      def initialize(response:)
        @response = response
        super("HTTP #{response.status}: #{response.body}")
      end
    end
  end
end
