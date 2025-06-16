require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Listings
    # GET /Listings
    # Get listings.
    # @return [Array, nil].
    def get_protocols
      Resources::Listing.parse(request(:get, 'listings/', nil, nil))
    end

    # GET /Listing/{id}
    # Get a listing.
    # @param [String] id A listing's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::listing, nil].
    def get_protocol(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Listing.parse(request(:get, "listings/#{id}"))
    end
  end
end
