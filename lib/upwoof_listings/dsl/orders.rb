require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Orders
    # GET /Orders
    # Get orders.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_orders(params: nil)
      Resources::Order.parse(request(:get, 'orders/', params, nil))
    end

    # GET /Order/{id}
    # Get a order.
    # @param [String] id A order's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Order, nil].
    def get_order(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Order.parse(request(:get, "orders/#{id}"))
    end

    # POST /orders
    # Create an order.
    # @param [Hash] params Order attributes.
    # @return [UpwoofListings::Resources::Order, nil].
    def create_order(params:)
      Resources::Order.parse(request(:post, 'orders/', params))
    end

    # PUT /orders/{id}
    # Update an order.
    # @param [String] id An order's ID.
    # @param [Hash] params Order attributes.
    # @return [UpwoofListings::Resources::Order, nil].
    def update_order(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Order.parse(request(:put, "orders/#{id}", params))
    end

    # PATCH /orders/{id}
    # Partially update an order.
    # @param [String] id An order's ID.
    # @param [Hash] params Order attributes.
    # @return [UpwoofListings::Resources::Order, nil].
    def patch_order(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Order.parse(request(:patch, "orders/#{id}", params))
    end

    # DELETE /orders/{id}
    # Delete an order.
    # @param [String] id An order's ID.
    # @return [Boolean].
    def delete_order(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "orders/#{id}").status == 204
    end
  end
end
