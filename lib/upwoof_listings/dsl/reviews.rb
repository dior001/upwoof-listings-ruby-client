require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Reviews
    # GET /listings/{id}/reviews
    # Get the published reviews for a listing.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) A hash of query parameters.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array, nil].
    def get_listing_reviews(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::Review.parse(request(:get, "listings/#{listing_id}/reviews", params, nil))
    end

    # POST /reservations/{id}/review
    # Create a review for a completed reservation.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params Review attributes.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Review, nil].
    def create_reservation_review(reservation_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::Review.parse(request(:post, "reservations/#{reservation_id}/review", params))
    end
  end
end
