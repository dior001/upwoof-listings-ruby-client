require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Pets
    # GET /Pets
    # Get pets.
    # @return [Array, nil].
    def get_pets
      Resources::Pet.parse(request(:get, 'pets/', nil, nil))
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
  end
end
