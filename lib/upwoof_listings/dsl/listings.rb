require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Listings
    # GET /Listings
    # Get listings.
    # @return [Array, nil].
    def get_listings
      Resources::Listing.parse(request(:get, 'listings/', nil, nil))
    end

    # GET /Listing/{id}
    # Get a listing.
    # @param [String] id A listing's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Listing, nil].
    def get_listing(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Listing.parse(request(:get, "listings/#{id}"))
    end

    # POST /listings
    # Create a listing.
    # @param [Hash] params Listing attributes.
    # @return [UpwoofListings::Resources::Listing, nil].
    def create_listing(params:)
      Resources::Listing.parse(request(:post, 'listings/', params))
    end

    # PUT /listings/{id}
    # Update a listing.
    # @param [String] id A listing's ID.
    # @param [Hash] params Listing attributes.
    # @return [UpwoofListings::Resources::Listing, nil].
    def update_listing(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Listing.parse(request(:put, "listings/#{id}", params))
    end

    # PATCH /listings/{id}
    # Partially update a listing.
    # @param [String] id A listing's ID.
    # @param [Hash] params Listing attributes.
    # @return [UpwoofListings::Resources::Listing, nil].
    def patch_listing(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Listing.parse(request(:patch, "listings/#{id}", params))
    end

    # DELETE /listings/{id}
    # Delete a listing.
    # @param [String] id A listing's ID.
    # @return [Boolean].
    def delete_listing(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "listings/#{id}").status == 204
    end
  end
end
