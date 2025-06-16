require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Accommodations
    # GET /Accommodations
    # Get accommodations.
    # @return [Array, nil].
    def get_accommodations
      Resources::Accommodation.parse(request(:get, 'accommodations/', nil, nil))
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
  end
end
