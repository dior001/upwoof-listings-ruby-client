require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Reservations
    # GET /Reservations
    # Get reservations.
    # @return [Array, nil].
    def get_reservations
      Resources::Reservation.parse(request(:get, 'reservations/', nil, nil))
    end

    # GET /Reservation/{id}
    # Get a reservation.
    # @param [String] id A reservation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def get_reservation(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Reservation.parse(request(:get, "reservations/#{id}"))
    end
  end
end
