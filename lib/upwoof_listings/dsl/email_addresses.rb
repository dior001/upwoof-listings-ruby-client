# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's role email addresses (<role_key>+<listing id>@upwoof.net) and the emails received at them.
  # Reading is any team member of the listing; creating, changing and deleting need owner/manager. An id that
  # isn't the listing's raises {UpwoofListings::Errors::ResourceNotFoundError}.
  module DSL::EmailAddresses
    # GET /listings/{id}/email_addresses
    # Ordered by role_key; always includes the bookings address.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ListingEmailAddress>, nil].
    def get_listing_email_addresses(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ListingEmailAddress.parse(request(:get, "listings/#{listing_id}/email_addresses", params, nil))
    end

    # GET /listings/{id}/email_addresses/{listing_email_address_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] listing_email_address_id An email address's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ListingEmailAddress, nil].
    def get_listing_email_address(listing_id:, listing_email_address_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || listing_email_address_id.blank?

      Resources::ListingEmailAddress.parse(
        request(:get, "listings/#{listing_id}/email_addresses/#{listing_email_address_id}")
      )
    end

    # POST /listings/{id}/email_addresses
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) for a taken or reserved role key.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params name and role_key ([a-z][a-z0-9-]{1,29}, unique at the listing, not reserved) required;
    #   active (default true), recipient_scope (owners_and_managers, the default, all_team or selected),
    #   selected_user_ids (team members, required when selected) and show_on_profile optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ListingEmailAddress, nil].
    def create_listing_email_address(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ListingEmailAddress.parse(request(:post, "listings/#{listing_id}/email_addresses", params))
    end

    # PATCH /listings/{id}/email_addresses/{listing_email_address_id}
    # Changes only the fields sent. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422, error
    # bookings_role_key) when changing the bookings address's role_key.
    # @param [String] listing_id A listing's ID.
    # @param [String] listing_email_address_id An email address's ID.
    # @param [Hash] params Email address attributes.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ListingEmailAddress, nil].
    def patch_listing_email_address(listing_id:, listing_email_address_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || listing_email_address_id.blank?

      Resources::ListingEmailAddress.parse(
        request(:patch, "listings/#{listing_id}/email_addresses/#{listing_email_address_id}", params)
      )
    end

    # DELETE /listings/{id}/email_addresses/{listing_email_address_id}
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422, error bookings_address) for the bookings address.
    # @param [String] listing_id A listing's ID.
    # @param [String] listing_email_address_id An email address's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_email_address(listing_id:, listing_email_address_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || listing_email_address_id.blank?

      request(:delete, "listings/#{listing_id}/email_addresses/#{listing_email_address_id}").status == 204
    end

    # GET /listings/{id}/inbound_emails
    # Emails received at the listing's addresses, newest first.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) outcome (posted, lead_created, lead_appended, ignored_automatic,
    #   ignored_own_team, rejected_unknown_address, rejected_sender, rejected_ambiguous, throttled, failed),
    #   since (ISO 8601), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::InboundEmailRecord>, nil].
    def get_listing_inbound_emails(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::InboundEmailRecord.parse(request(:get, "listings/#{listing_id}/inbound_emails", params, nil))
    end
  end
end
