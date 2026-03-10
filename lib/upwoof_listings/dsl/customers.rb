require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Customers
    # GET /Customers
    # Get customers.
    # @return [Array, nil].
    def get_customers
      Resources::Customer.parse(request(:get, 'customers/', nil, nil))
    end

    # GET /Customer/{id}
    # Get a customer.
    # @param [String] id A customer's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Customer, nil].
    def get_customer(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Customer.parse(request(:get, "customers/#{id}"))
    end

    # POST /customers
    # Create a customer.
    # @param [Hash] params Customer attributes.
    # @return [UpwoofListings::Resources::Customer, nil].
    def create_customer(params:)
      Resources::Customer.parse(request(:post, 'customers/', params))
    end

    # PUT /customers/{id}
    # Update a customer.
    # @param [String] id A customer's ID.
    # @param [Hash] params Customer attributes.
    # @return [UpwoofListings::Resources::Customer, nil].
    def update_customer(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Customer.parse(request(:put, "customers/#{id}", params))
    end

    # PATCH /customers/{id}
    # Partially update a customer.
    # @param [String] id A customer's ID.
    # @param [Hash] params Customer attributes.
    # @return [UpwoofListings::Resources::Customer, nil].
    def patch_customer(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Customer.parse(request(:patch, "customers/#{id}", params))
    end

    # DELETE /customers/{id}
    # Delete a customer.
    # @param [String] id A customer's ID.
    # @return [Boolean].
    def delete_customer(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "customers/#{id}").status == 204
    end
  end
end
