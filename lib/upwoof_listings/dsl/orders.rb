require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Orders
    # GET /Orders
    # Get orders.
    # @return [Array, nil].
    def get_orders
      Resources::Order.parse(request(:get, 'orders/', nil, nil))
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
  end
end
