require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Users
    # GET /Users
    # Get users.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_users(params: nil)
      Resources::User.parse(request(:get, 'users/', params, nil))
    end

    # GET /users/me
    # Get current user.
    # @return [UpwoofListings::Resources::User, nil].
    def get_users_me
      Resources::User.parse(request(:get, 'users/me'))
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

    # POST /users
    # Create a user.
    # @param [Hash] params User attributes.
    # @return [UpwoofListings::Resources::User, nil].
    def create_user(params:)
      Resources::User.parse(request(:post, 'users/', params))
    end

    # PUT /users/{id}
    # Update a user.
    # @param [String] id A user's ID.
    # @param [Hash] params User attributes.
    # @return [UpwoofListings::Resources::User, nil].
    def update_user(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::User.parse(request(:put, "users/#{id}", params))
    end

    # PATCH /users/{id}
    # Partially update a user.
    # @param [String] id A user's ID.
    # @param [Hash] params User attributes.
    # @return [UpwoofListings::Resources::User, nil].
    def patch_user(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::User.parse(request(:patch, "users/#{id}", params))
    end

    # DELETE /users/{id}
    # Delete a user.
    # @param [String] id A user's ID.
    # @return [Boolean].
    def delete_user(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "users/#{id}").status == 204
    end
  end
end
