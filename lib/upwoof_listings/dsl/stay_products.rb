# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Shop products added to a stay's bill. Any team member of the listing; a reservation, product or item that isn't
  # reachable raises {UpwoofListings::Errors::ResourceNotFoundError}.
  module DSL::StayProducts
    # GET /listings/{id}/stay_products
    # Active products priced in the listing's currency, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::StayProduct>, nil].
    def get_listing_stay_products(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::StayProduct.parse(request(:get, "listings/#{listing_id}/stay_products", params, nil))
    end

    # GET /reservations/{reservation_id}/retail_items
    # In the order added.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ReservationRetailItem>, nil].
    def get_reservation_retail_items(reservation_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::ReservationRetailItem.parse(request(:get, "reservations/#{reservation_id}/retail_items", params, nil))
    end

    # POST /reservations/{reservation_id}/retail_items
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when the stay's order isn't open, the product isn't
    # offered, is already on the stay (change its quantity with patch_reservation_retail_item instead), the quantity is
    # invalid or not in stock. The customer is told, as on the web.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params retail_product_id required (one of the stay's listing's products); quantity optional
    #   (1-99, default 1).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ReservationRetailItem, nil].
    def create_reservation_retail_item(reservation_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::ReservationRetailItem.parse(request(:post, "reservations/#{reservation_id}/retail_items", params))
    end

    # PATCH /reservations/{reservation_id}/retail_items/{retail_item_id}
    # Changes how many of the product the stay carries, at the price it was added at. The same quantity again changes
    # nothing; the customer isn't told. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) once the stay's
    # order is invoiced, or for a bad quantity or not enough in stock.
    # @param [String] reservation_id A reservation's ID.
    # @param [String] retail_item_id A stay's retail item ID.
    # @param [Hash] params quantity required (1-99).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ReservationRetailItem, nil].
    def patch_reservation_retail_item(reservation_id:, retail_item_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank? || retail_item_id.blank?

      Resources::ReservationRetailItem.parse(
        request(:patch, "reservations/#{reservation_id}/retail_items/#{retail_item_id}", params)
      )
    end

    # DELETE /reservations/{reservation_id}/retail_items/{retail_item_id}
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) once the stay's order is invoiced.
    # @param [String] reservation_id A reservation's ID.
    # @param [String] retail_item_id A stay's retail item ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_reservation_retail_item(reservation_id:, retail_item_id:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank? || retail_item_id.blank?

      request(:delete, "reservations/#{reservation_id}/retail_items/#{retail_item_id}").status == 204
    end
  end
end
