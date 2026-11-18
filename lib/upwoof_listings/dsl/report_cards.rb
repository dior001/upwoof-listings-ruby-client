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

    # GET /listings/{id}/report_cards
    # The cards on the listing's stays for one day, by stay then pet.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) date (YYYY-MM-DD, default today in the listing's zone), status (draft or
    #   published), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ReportCard>, nil].
    def get_listing_report_cards(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ReportCard.parse(request(:get, "listings/#{listing_id}/report_cards", params, nil))
    end

    # POST /listings/{id}/report_cards/start
    # Start today's draft for every active pet on every checked-in stay without one. Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) when the listing has report cards turned off.
    # @param [String] listing_id A listing's ID.
    # @param [Boolean] include_care_log Fill the drafts from the care log.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Object, nil] created_count, skipped_count and date.
    def start_listing_report_cards(listing_id:, include_care_log: false)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::Object.parse(
        request(:post, "listings/#{listing_id}/report_cards/start", { include_care_log: include_care_log })
      )
    end

    # POST /listings/{id}/report_cards/publish
    # Send every draft for today (each customer is told once). Raises {UpwoofListings::Errors::ValidationError}
    # (HTTP 422) when the listing has report cards turned off.
    # @param [String] listing_id A listing's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Object, nil] published_count and date.
    def publish_listing_report_cards(listing_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::Object.parse(request(:post, "listings/#{listing_id}/report_cards/publish"))
    end

    # GET /report_cards/{id}/photos
    # Oldest first. Each url is valid for 15 minutes.
    # @param [String] report_card_id A report card's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ReportCardPhoto>, nil].
    def get_report_card_photos(report_card_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if report_card_id.blank?

      Resources::ReportCardPhoto.parse(request(:get, "report_cards/#{report_card_id}/photos", params, nil))
    end

    # POST /report_cards/{id}/photos/{photo_id}/share
    # Share the photo in the listing's website photo stream (idempotent). Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) when the listing's photo stream is off.
    # @param [String] report_card_id A report card's ID.
    # @param [String] photo_id The photo's ID on the card.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ReportCardPhoto, nil].
    def share_report_card_photo(report_card_id:, photo_id:)
      raise ArgumentError, 'ID cannot be blank' if report_card_id.blank? || photo_id.blank?

      Resources::ReportCardPhoto.parse(request(:post, "report_cards/#{report_card_id}/photos/#{photo_id}/share"))
    end

    # DELETE /report_cards/{id}/photos/{photo_id}/share
    # Raises {UpwoofListings::Errors::ResourceNotFoundError} when the photo isn't shared.
    # @param [String] report_card_id A report card's ID.
    # @param [String] photo_id The photo's ID on the card.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def unshare_report_card_photo(report_card_id:, photo_id:)
      raise ArgumentError, 'ID cannot be blank' if report_card_id.blank? || photo_id.blank?

      request(:delete, "report_cards/#{report_card_id}/photos/#{photo_id}/share").status == 204
    end
  end
end
