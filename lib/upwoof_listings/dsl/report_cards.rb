require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::ReportCards
    # GET /reservations/{reservation_id}/report_cards
    # List published report cards for a reservation.
    # @param [String] reservation_id A reservation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ReportCard>, nil].
    def get_reservation_report_cards(reservation_id:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::ReportCard.parse(request(:get, "reservations/#{reservation_id}/report_cards", nil, nil))
    end

    # POST /reservations/{reservation_id}/report_cards
    # Create a report card for a reservation.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params Report card attributes (pet_id, date, meals_eaten, water_intake, energy_level,
    #   mood, potty_breaks, activities, notes).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ReportCard, nil].
    def create_reservation_report_card(reservation_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::ReportCard.parse(request(:post, "reservations/#{reservation_id}/report_cards", params))
    end
  end
end
