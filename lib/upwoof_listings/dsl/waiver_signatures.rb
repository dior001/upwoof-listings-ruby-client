require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::WaiverSignatures
    # GET /reservations/{id}/waiver_signature
    # Get the signed liability waiver for a reservation, if any.
    # @param [String] reservation_id A reservation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::WaiverSignature, nil].
    def get_reservation_waiver_signature(reservation_id:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::WaiverSignature.parse(request(:get, "reservations/#{reservation_id}/waiver_signature", nil, nil))
    end
  end
end
