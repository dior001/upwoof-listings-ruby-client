require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Pets
    # GET /Pets
    # Get pets.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_pets(params: nil)
      Resources::Pet.parse(request(:get, 'pets/', params, nil))
    end

    # GET /Pet/{id}
    # Get a pet.
    # @param [String] id A pet's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Pet, nil].
    def get_pet(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Pet.parse(request(:get, "pets/#{id}"))
    end

    # POST /pets
    # Create a pet.
    # @param [Hash] params Pet attributes.
    # @return [UpwoofListings::Resources::Pet, nil].
    def create_pet(params:)
      Resources::Pet.parse(request(:post, 'pets/', params))
    end

    # PUT /pets/{id}
    # Update a pet.
    # @param [String] id A pet's ID.
    # @param [Hash] params Pet attributes.
    # @return [UpwoofListings::Resources::Pet, nil].
    def update_pet(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Pet.parse(request(:put, "pets/#{id}", params))
    end

    # PATCH /pets/{id}
    # Partially update a pet.
    # @param [String] id A pet's ID.
    # @param [Hash] params Pet attributes.
    # @return [UpwoofListings::Resources::Pet, nil].
    def patch_pet(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Pet.parse(request(:patch, "pets/#{id}", params))
    end

    # DELETE /pets/{id}
    # Delete a pet.
    # @param [String] id A pet's ID.
    # @return [Boolean].
    def delete_pet(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "pets/#{id}").status == 204
    end

    # POST /pets/{id}/deactivation
    # Mark a pet inactive. Upcoming stays a recurring schedule booked for this pet alone that still await
    # review are cancelled. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when the pet is
    # already inactive.
    # @param [String] id A pet's ID.
    # @param [String] deactivation_reason passed_away, rehomed or other.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Pet, nil].
    def deactivate_pet(id:, deactivation_reason:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Deactivation reason cannot be blank' if deactivation_reason.blank?

      Resources::Pet.parse(request(:post, "pets/#{id}/deactivation", { deactivation_reason: deactivation_reason }))
    end

    # DELETE /pets/{id}/deactivation
    # Make an inactive pet active again. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when it is
    # already active.
    # @param [String] id A pet's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Pet, nil].
    def reactivate_pet(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Pet.parse(request(:delete, "pets/#{id}/deactivation"))
    end
  end
end
