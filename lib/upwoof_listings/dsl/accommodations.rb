require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Accommodations
    # GET /Accommodations
    # Get accommodations.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_accommodations(params: nil)
      Resources::Accommodation.parse(request(:get, 'accommodations/', params, nil))
    end

    # GET /Accommodation/{id}
    # Get a accommodation.
    # @param [String] id A accommodation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Accommodation, nil].
    def get_accommodation(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Accommodation.parse(request(:get, "accommodations/#{id}"))
    end

    # POST /accommodations
    # Create a accommodation.
    # @param [Hash] params Accommodation attributes.
    # @return [UpwoofListings::Resources::Accommodation, nil].
    def create_accommodation(params:)
      Resources::Accommodation.parse(request(:post, 'accommodations/', params))
    end

    # PUT /accommodations/{id}
    # Update a accommodation.
    # @param [String] id A accommodation's ID.
    # @param [Hash] params Accommodation attributes.
    # @return [UpwoofListings::Resources::Accommodation, nil].
    def update_accommodation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Accommodation.parse(request(:put, "accommodations/#{id}", params))
    end

    # PATCH /accommodations/{id}
    # Partially update a accommodation.
    # @param [String] id A accommodation's ID.
    # @param [Hash] params Accommodation attributes.
    # @return [UpwoofListings::Resources::Accommodation, nil].
    def patch_accommodation(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Accommodation.parse(request(:patch, "accommodations/#{id}", params))
    end

    # DELETE /accommodations/{id}
    # Delete a accommodation.
    # @param [String] id A accommodation's ID.
    # @return [Boolean].
    def delete_accommodation(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "accommodations/#{id}").status == 204
    end
  end
end
