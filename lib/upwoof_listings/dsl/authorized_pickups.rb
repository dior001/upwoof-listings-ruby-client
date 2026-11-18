# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # The people a customer has authorised to collect their pets. Any team member (admin or staff) of listing_id,
  # which every method needs; the customer must be in that listing's (group's) customer directory, else
  # {UpwoofListings::Errors::ResourceNotFoundError}.
  module DSL::AuthorizedPickups
    # GET /customers/{customer_id}/authorized_pickups
    # By name, every pickup the listing's group holds for the same person.
    # @param [String] customer_id A customer's ID.
    # @param [String] listing_id One of the caller's listings.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::AuthorizedPickup>, nil].
    def get_customer_authorized_pickups(customer_id:, listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank? || listing_id.blank?

      Resources::AuthorizedPickup.parse(
        request(:get, "customers/#{customer_id}/authorized_pickups", (params || {}).merge(listing_id: listing_id), nil)
      )
    end

    # GET /customers/{customer_id}/authorized_pickups/{id}
    # @param [String] customer_id A customer's ID.
    # @param [String] authorized_pickup_id An authorized pickup's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AuthorizedPickup, nil].
    def get_customer_authorized_pickup(customer_id:, authorized_pickup_id:, listing_id:)
      if customer_id.blank? || authorized_pickup_id.blank? || listing_id.blank?
        raise ArgumentError, 'ID cannot be blank'
      end

      Resources::AuthorizedPickup.parse(
        request(:get, "customers/#{customer_id}/authorized_pickups/#{authorized_pickup_id}",
                { listing_id: listing_id }, nil)
      )
    end

    # POST /customers/{customer_id}/authorized_pickups
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) for a blank or too-long value.
    # @param [String] customer_id A customer's ID.
    # @param [Hash] params listing_id and name (at most 100) required; relationship (60), phone (40), notes (500)
    #   optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AuthorizedPickup, nil].
    def create_customer_authorized_pickup(customer_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank?

      Resources::AuthorizedPickup.parse(request(:post, "customers/#{customer_id}/authorized_pickups", params))
    end

    # PATCH /customers/{customer_id}/authorized_pickups/{id}
    # Changes only the fields sent.
    # @param [String] customer_id A customer's ID.
    # @param [String] authorized_pickup_id An authorized pickup's ID.
    # @param [Hash] params listing_id required; name, relationship, phone, notes optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AuthorizedPickup, nil].
    def patch_customer_authorized_pickup(customer_id:, authorized_pickup_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank? || authorized_pickup_id.blank?

      Resources::AuthorizedPickup.parse(
        request(:patch, "customers/#{customer_id}/authorized_pickups/#{authorized_pickup_id}", params)
      )
    end

    # DELETE /customers/{customer_id}/authorized_pickups/{id}
    # @param [String] customer_id A customer's ID.
    # @param [String] authorized_pickup_id An authorized pickup's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_customer_authorized_pickup(customer_id:, authorized_pickup_id:, listing_id:)
      if customer_id.blank? || authorized_pickup_id.blank? || listing_id.blank?
        raise ArgumentError, 'ID cannot be blank'
      end

      request(:delete, "customers/#{customer_id}/authorized_pickups/#{authorized_pickup_id}",
              { listing_id: listing_id }).status == 204
    end
  end
end
