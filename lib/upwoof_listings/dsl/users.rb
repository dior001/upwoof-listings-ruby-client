require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Users
    # GET /Users
    # Get users.
    # @return [Array, nil].
    def get_users
      Resources::User.parse(request(:get, 'users/', nil, nil))
    end

    # GET /User/{id}
    # Get a user.
    # @param [String] id A user's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::User, nil].
    def get_user(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::User.parse(request(:get, "users/#{id}"))
    end
  end
end
