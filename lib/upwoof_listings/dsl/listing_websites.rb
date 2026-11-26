# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's UpWoof website (owner/manager only): its address, theme, palette, booking switch, own domain and
  # billing status. Subscribing and cancelling happen in the listings manager.
  module DSL::ListingWebsites
    # GET /listings/{id}/website
    # @param [String] listing_id A listing's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @raise [ResourceNotFoundError] If the listing has no website.
    # @return [UpwoofListings::Resources::ListingWebsite].
    def get_listing_website(listing_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ListingWebsite.parse(request(:get, "listings/#{listing_id}/website"))
    end

    # PATCH /listings/{id}/website
    # Changes only the fields sent: +theme+ (classic, modern, playful), +palette+ (+primary+, +secondary+,
    # +accent+ as #rrggbb; a colour sent blank goes back to the theme's own), +bookings_enabled+ and +custom_domain+
    # (blank detaches it).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params The fields to change.
    # @raise [ArgumentError] If the method arguments are blank.
    # @raise [ValidationError] If a value is refused (or the domain, `custom_domain_refused`).
    # @return [UpwoofListings::Resources::ListingWebsite].
    def update_listing_website(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ListingWebsite.parse(request(:patch, "listings/#{listing_id}/website", params))
    end
  end
end
