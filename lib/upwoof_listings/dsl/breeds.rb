require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Breeds
    # GET /breeds
    # Get breeds.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_breeds(params: nil)
      Resources::Breed.parse(request(:get, 'breeds/', params, nil))
    end

    # GET /breeds/{id}
    # Get a breed.
    # @param [String] id A breed's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Breed, nil].
    def get_breed(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Breed.parse(request(:get, "breeds/#{id}"))
    end

    # POST /breeds
    # Create a breed.
    # @param [Hash] params Breed attributes.
    # @return [UpwoofListings::Resources::Breed, nil].
    def create_breed(params:)
      Resources::Breed.parse(request(:post, 'breeds/', params))
    end

    # PUT /breeds/{id}
    # Update a breed.
    # @param [String] id A breed's ID.
    # @param [Hash] params Breed attributes.
    # @return [UpwoofListings::Resources::Breed, nil].
    def update_breed(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Breed.parse(request(:put, "breeds/#{id}", params))
    end

    # PATCH /breeds/{id}
    # Partially update a breed.
    # @param [String] id A breed's ID.
    # @param [Hash] params Breed attributes.
    # @return [UpwoofListings::Resources::Breed, nil].
    def patch_breed(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Breed.parse(request(:patch, "breeds/#{id}", params))
    end

    # DELETE /breeds/{id}
    # Delete a breed.
    # @param [String] id A breed's ID.
    # @return [Boolean].
    def delete_breed(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "breeds/#{id}").status == 204
    end
  end
end
