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
    # Book a confirmed stay, as a team member booking it would: the optional accommodation_id (else the best fit
    # for the pet), the day's first drop-off and last pick-up window, and its order. A stay that can't be booked
    # (an inactive pet, a full or closed unit, the daily dog or cat limit, a restricted breed, a missing
    # evaluation, another listing's accommodation) raises {UpwoofListings::Errors::ValidationError} (HTTP 422,
    # its error code and message say why) and nothing is created.
    # @param [Hash] params customer_id, listing_id, pet_id, when_reservation_start, when_reservation_finish and an
    #   optional accommodation_id.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def create_reservation(params:)
      Resources::Reservation.parse(request(:post, 'reservations/', params))
    end

    # PUT /reservations/{id}
    # Update a reservation.
    # Changing when_reservation_start/when_reservation_finish runs the same availability check as the
    # listing manager, rebuilds the order and fires reservation.duration_changed (and its webhook).
    # @raise [UpwoofListings::Errors::ValidationError] (HTTP 422) If the API refuses the change; its
    #   reasons are in #errors. So does a reservation whose every pet is inactive (deactivated); its dates are
    #   left unchanged.
    # @param [String] id A reservation's ID.
    # @param [Hash] params Reservation attributes.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def update_reservation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Reservation.parse(request(:put, "reservations/#{id}", params))
    end

    # PATCH /reservations/{id}
    # Partially update a reservation.
    # Changing when_reservation_start/when_reservation_finish runs the same availability check as the
    # listing manager, rebuilds the order and fires reservation.duration_changed (and its webhook).
    # @raise [UpwoofListings::Errors::ValidationError] (HTTP 422) If the API refuses the change; its
    #   reasons are in #errors. So does a reservation whose every pet is inactive (deactivated); its dates are
    #   left unchanged.
    # @param [String] id A reservation's ID.
    # @param [Hash] params Reservation attributes.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def patch_reservation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Reservation.parse(request(:patch, "reservations/#{id}", params))
    end

    # POST /reservations/{id}/cancel
    # Cancel an awaiting_review or confirmed reservation on the listing's own behalf: a phone cancellation, or
    # an off-platform booking with no customer login to cancel it themselves. mode apply_policy (the default)
    # applies the listing's own cancellation policy, exactly as a customer self-cancelling would; mode
    # full_refund (owner/manager only) overrides it and refunds any deposit paid in full, regardless of the
    # cancellation window.
    # @raise [ArgumentError] If id or reason is blank.
    # @raise [UpwoofListings::Errors::ValidationError] (HTTP 422) If the cancellation itself is refused (e.g.
    #   an unrefunded payment blocks it); its reasons are in #errors.
    # @param [String] id A reservation's ID.
    # @param [String] reason Why the reservation is being cancelled.
    # @param [String] mode (optional) apply_policy (the default) or full_refund.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def cancel_reservation(id:, reason:, mode: nil)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Reason cannot be blank' if reason.blank?

      params = { reason: reason }
      params[:mode] = mode if mode.present?
      Resources::Reservation.parse(request(:post, "reservations/#{id}/cancel", params))
    end

    # PATCH /reservations/{reservation_id}/unit_assignments/{unit_assignment_id}
    # Place one of a stay's accommodation_assignments in a physical unit (run or kennel) of its accommodation, or,
    # with no accommodation_unit_id, take it out of its unit. Any team member of the stay's listing. Raises
    # {UpwoofListings::Errors::ResourceNotFoundError} for a stay that isn't at the caller's listings, an assignment
    # that isn't the stay's, or a unit that isn't an active unit of its accommodation, and
    # {UpwoofListings::Errors::ValidationError} (HTTP 422, "The unit is taken by another stay on some of these
    # nights") when another stay holds the unit on any of this stay's nights.
    # @param [String] reservation_id A reservation's ID.
    # @param [String] unit_assignment_id The id of one of the reservation's accommodation_assignments.
    # @param [String] accommodation_unit_id (optional) An active unit of that assignment's accommodation.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ReservationAccommodationAssignment, nil].
    def update_reservation_unit_assignment(reservation_id:, unit_assignment_id:, accommodation_unit_id: nil)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank? || unit_assignment_id.blank?

      Resources::ReservationAccommodationAssignment.parse(
        request(:patch, "reservations/#{reservation_id}/unit_assignments/#{unit_assignment_id}",
                { accommodation_unit_id: accommodation_unit_id })
      )
    end
  end
end
