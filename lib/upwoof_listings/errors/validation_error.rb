require 'upwoof_listings/errors/client_error'

module UpwoofListings
  module Errors
    # HTTP 422: the API refused the request. {#errors} holds its messages, e.g. a reservation date
    # change that fails the availability check, or a gift card that can't be redeemed against this order.
    class ValidationError < ClientError
    end
  end
end
