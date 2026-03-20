require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Reservations
    # GET /Reservations
    # Get reservations.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_reservations(params: nil)
      Resources::Reservation.parse(request(:get, 'reservations/', params, nil))
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

    # POST /reservations
    # Create a reservation.
    # @param [Hash] params Reservation attributes.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def create_reservation(params:)
      Resources::Reservation.parse(request(:post, 'reservations/', params))
    end

    # PUT /reservations/{id}
    # Update a reservation.
    # @param [String] id A reservation's ID.
    # @param [Hash] params Reservation attributes.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def update_reservation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Reservation.parse(request(:put, "reservations/#{id}", params))
    end

    # PATCH /reservations/{id}
    # Partially update a reservation.
    # @param [String] id A reservation's ID.
    # @param [Hash] params Reservation attributes.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def patch_reservation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Reservation.parse(request(:patch, "reservations/#{id}", params))
    end

    # DELETE /reservations/{id}
    # Delete a reservation.
    # @param [String] id A reservation's ID.
    # @return [Boolean].
    def delete_reservation(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "reservations/#{id}").status == 204
    end
  end
end
