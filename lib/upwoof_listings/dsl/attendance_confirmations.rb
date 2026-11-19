# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # "Still coming?" requests sent to customers (read only). Any team member of the stay's listing. A request's status
  # is pending (no answer), confirmed (coming) or declined (can't make it); visit_on is the day asked about for a
  # multi-day daycare stay (one request per day), nil for the whole stay, and visit_date is visit_on else the stay's
  # first day.
  module DSL::AttendanceConfirmations
    # GET /reservations/{reservation_id}/attendance_confirmations
    # A stay's requests, by id.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::AttendanceConfirmation>, nil].
    def get_reservation_attendance_confirmations(reservation_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::AttendanceConfirmation.parse(
        request(:get, "reservations/#{reservation_id}/attendance_confirmations", params, nil)
      )
    end

    # GET /listings/{id}/attendance_confirmations
    # A listing's requests, by id. A bad date or status raises {UpwoofListings::Errors::ClientError} (HTTP 400).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) date (YYYY-MM-DD: requests asking about that day, i.e. visit_on that day or a
    #   whole-stay request whose stay starts that day), status (pending, confirmed, declined), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::AttendanceConfirmation>, nil].
    def get_listing_attendance_confirmations(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::AttendanceConfirmation.parse(
        request(:get, "listings/#{listing_id}/attendance_confirmations", params, nil)
      )
    end
  end
end
