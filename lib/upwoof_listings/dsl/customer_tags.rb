# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's customer tags. Owner/manager of the listing only (a staff member gets ClientError, HTTP 403); a tag
  # that isn't the listing's raises {UpwoofListings::Errors::ResourceNotFoundError}. Filter get_customers by a tag
  # with customer_tag_id, and limit a pricing rule to tags with customer_tag_ids.
  module DSL::CustomerTags
    # GET /listings/{id}/customer_tags
    # By name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::CustomerTag>, nil].
    def get_listing_customer_tags(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::CustomerTag.parse(request(:get, "listings/#{listing_id}/customer_tags", params, nil))
    end

    # POST /listings/{id}/customer_tags
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) for a blank, too-long or duplicate name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params name required (at most 40, unique per listing ignoring case); colour optional
    #   (secondary, primary, info, success, warning, danger, dark; default secondary).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CustomerTag, nil].
    def create_listing_customer_tag(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::CustomerTag.parse(request(:post, "listings/#{listing_id}/customer_tags", params))
    end

    # PATCH /listings/{id}/customer_tags/{tag_id}
    # Changes only the name/colour sent.
    # @param [String] listing_id A listing's ID.
    # @param [String] tag_id A customer tag's ID.
    # @param [Hash] params name, colour.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CustomerTag, nil].
    def patch_listing_customer_tag(listing_id:, tag_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || tag_id.blank?

      Resources::CustomerTag.parse(request(:patch, "listings/#{listing_id}/customer_tags/#{tag_id}", params))
    end

    # DELETE /listings/{id}/customer_tags/{tag_id}
    # Takes the tag off every customer. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) while a pricing
    # rule is limited to it.
    # @param [String] listing_id A listing's ID.
    # @param [String] tag_id A customer tag's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_customer_tag(listing_id:, tag_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || tag_id.blank?

      request(:delete, "listings/#{listing_id}/customer_tags/#{tag_id}").status == 204
    end

    # POST /listings/{id}/customer_tags/{tag_id}/customers
    # Put the tag on a customer of the listing's group. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422)
    # when the customer already carries it.
    # @param [String] listing_id A listing's ID.
    # @param [String] tag_id A customer tag's ID.
    # @param [String] customer_id A customer's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CustomerTagging, nil].
    def tag_listing_customer(listing_id:, tag_id:, customer_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || tag_id.blank? || customer_id.blank?

      Resources::CustomerTagging.parse(
        request(:post, "listings/#{listing_id}/customer_tags/#{tag_id}/customers", { customer_id: customer_id })
      )
    end

    # DELETE /listings/{id}/customer_tags/{tag_id}/customers
    # Take the tag off a customer; {UpwoofListings::Errors::ResourceNotFoundError} when the customer doesn't carry
    # it.
    # @param [String] listing_id A listing's ID.
    # @param [String] tag_id A customer tag's ID.
    # @param [String] customer_id A customer's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def untag_listing_customer(listing_id:, tag_id:, customer_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || tag_id.blank? || customer_id.blank?

      request(:delete, "listings/#{listing_id}/customer_tags/#{tag_id}/customers",
              { customer_id: customer_id }).status == 204
    end
  end
end
