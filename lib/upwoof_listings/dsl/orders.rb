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
    # @param [Hash] params Order attributes. An optional +:listing_id+ key picks which of the
    #   caller's listings the order is for; it defaults to the caller's first listing.
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

    # POST /orders/{id}/apply_promo_code
    # Apply a promo code to an order as a discount line item, up to the order's remaining
    # balance. Raises a {UpwoofListings::Errors::ClientError} (HTTP 404) for an unknown code,
    # or a validation error (HTTP 422) if the code can't be applied to this order.
    # @param [String] id An order's ID.
    # @param [String] code The promo code.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Order, nil].
    def apply_promo_code(id:, code:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Code cannot be blank' if code.blank?

      Resources::Order.parse(request(:post, "orders/#{id}/apply_promo_code", { code: }))
    end

    # POST /orders/{id}/redeem_gift_card
    # Redeem a gift card against an order as a discount line item, up to whichever is smaller:
    # the order's remaining balance or the gift card's remaining balance. Raises a
    # {UpwoofListings::Errors::ClientError} (HTTP 404) for an unknown code, or a validation
    # error (HTTP 422) if the card can't be redeemed against this order.
    # @param [String] id An order's ID.
    # @param [String] code The gift card code.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Order, nil].
    def redeem_gift_card(id:, code:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Code cannot be blank' if code.blank?

      Resources::Order.parse(request(:post, "orders/#{id}/redeem_gift_card", { code: }))
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
