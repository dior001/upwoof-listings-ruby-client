require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::AccommodationTypes
    # GET /accommodation_types
    # Get accommodation types.
    # @return [Array, nil].
    def get_accommodation_types
      Resources::AccommodationType.parse(request(:get, 'accommodation_types/', nil, nil))
    end

    # GET /accommodation_types/{id}
    # Get an accommodation type.
    # @param [String] id An accommodation type's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AccommodationType, nil].
    def get_accommodation_type(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AccommodationType.parse(request(:get, "accommodation_types/#{id}"))
    end

    # POST /accommodation_types
    # Create an accommodation type.
    # @param [Hash] params Accommodation type attributes.
    # @return [UpwoofListings::Resources::AccommodationType, nil].
    def create_accommodation_type(params:)
      Resources::AccommodationType.parse(request(:post, 'accommodation_types/', params))
    end

    # PUT /accommodation_types/{id}
    # Update an accommodation type.
    # @param [String] id An accommodation type's ID.
    # @param [Hash] params Accommodation type attributes.
    # @return [UpwoofListings::Resources::AccommodationType, nil].
    def update_accommodation_type(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AccommodationType.parse(request(:put, "accommodation_types/#{id}", params))
    end

    # PATCH /accommodation_types/{id}
    # Partially update an accommodation type.
    # @param [String] id An accommodation type's ID.
    # @param [Hash] params Accommodation type attributes.
    # @return [UpwoofListings::Resources::AccommodationType, nil].
    def patch_accommodation_type(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AccommodationType.parse(request(:patch, "accommodation_types/#{id}", params))
    end

    # DELETE /accommodation_types/{id}
    # Delete an accommodation type.
    # @param [String] id An accommodation type's ID.
    # @return [Boolean].
    def delete_accommodation_type(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "accommodation_types/#{id}").status == 204
    end
  end
end
