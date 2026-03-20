require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::AnimalTypes
    # GET /animal_types
    # Get animal types.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_animal_types(params: nil)
      Resources::AnimalType.parse(request(:get, 'animal_types/', params, nil))
    end

    # GET /animal_types/{id}
    # Get an animal type.
    # @param [String] id An animal type's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AnimalType, nil].
    def get_animal_type(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AnimalType.parse(request(:get, "animal_types/#{id}"))
    end

    # POST /animal_types
    # Create an animal type.
    # @param [Hash] params Animal type attributes.
    # @return [UpwoofListings::Resources::AnimalType, nil].
    def create_animal_type(params:)
      Resources::AnimalType.parse(request(:post, 'animal_types/', params))
    end

    # PUT /animal_types/{id}
    # Update an animal type.
    # @param [String] id An animal type's ID.
    # @param [Hash] params Animal type attributes.
    # @return [UpwoofListings::Resources::AnimalType, nil].
    def update_animal_type(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AnimalType.parse(request(:put, "animal_types/#{id}", params))
    end

    # PATCH /animal_types/{id}
    # Partially update an animal type.
    # @param [String] id An animal type's ID.
    # @param [Hash] params Animal type attributes.
    # @return [UpwoofListings::Resources::AnimalType, nil].
    def patch_animal_type(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::AnimalType.parse(request(:patch, "animal_types/#{id}", params))
    end

    # DELETE /animal_types/{id}
    # Delete an animal type.
    # @param [String] id An animal type's ID.
    # @return [Boolean].
    def delete_animal_type(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "animal_types/#{id}").status == 204
    end
  end
end
