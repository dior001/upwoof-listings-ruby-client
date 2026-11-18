# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's custom fields, and answering them on customers, pets and reservations.
  #
  # The update methods take +custom_fields+, a non-empty array of
  # +{ custom_field_definition_id:, value: }+: a String (text, select, ISO 8601 date), a Number, a Boolean
  # (yes_no) or an Array of Strings (multi_select); nil or "" clears the answer. Only the fields sent change,
  # and the record comes back with its updated +custom_fields+. A refusal raises
  # {UpwoofListings::Errors::ValidationError} (HTTP 422, nothing saved): an id that isn't one of the listing's
  # fields for that record type (+body['unknown_custom_field_ids']+), or a refused answer (+body['errors']+,
  # keyed by definition id).
  module DSL::CustomFields
    # GET /listings/{listing_id}/custom_field_definitions
    # A listing's own custom fields plus its listing group's group-wide ones.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) record_type (customer, pet, reservation, incident_report), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::CustomFieldDefinition>, nil].
    def get_listing_custom_field_definitions(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::CustomFieldDefinition.parse(
        request(:get, "listings/#{listing_id}/custom_field_definitions", params, nil)
      )
    end

    # PUT /customers/{id}/custom_fields
    # @param [String] id A customer's ID.
    # @param [String] listing_id The listing whose fields are answered.
    # @param [Array<Hash>] custom_fields The answers.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Customer, nil].
    def update_customer_custom_fields(id:, listing_id:, custom_fields:)
      Resources::Customer.parse(put_custom_fields('customers', id, listing_id, custom_fields))
    end

    # PUT /pets/{id}/custom_fields
    # @param [String] id A pet's ID.
    # @param [String] listing_id The listing whose fields are answered.
    # @param [Array<Hash>] custom_fields The answers.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Pet, nil].
    def update_pet_custom_fields(id:, listing_id:, custom_fields:)
      Resources::Pet.parse(put_custom_fields('pets', id, listing_id, custom_fields))
    end

    # PUT /reservations/{id}/custom_fields
    # @param [String] id A reservation's ID.
    # @param [String] listing_id The listing whose fields are answered.
    # @param [Array<Hash>] custom_fields The answers.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Reservation, nil].
    def update_reservation_custom_fields(id:, listing_id:, custom_fields:)
      Resources::Reservation.parse(put_custom_fields('reservations', id, listing_id, custom_fields))
    end

    private

    def put_custom_fields(collection, id, listing_id, custom_fields)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Listing ID cannot be blank' if listing_id.blank?
      raise ArgumentError, 'Custom fields cannot be blank' if custom_fields.blank?

      request(:put, "#{collection}/#{id}/custom_fields", { listing_id: listing_id, custom_fields: custom_fields })
    end
  end
end
