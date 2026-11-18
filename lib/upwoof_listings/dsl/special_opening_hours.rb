# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's special-date opening hours.
  module DSL::SpecialOpeningHours
    # GET /listings/{id}/special_opening_hours
    # By date, from +from+ (YYYY-MM-DD; default today in the listing's time zone). Times are "HH:MM" wall
    # clock in the listing's time zone; an empty +pick_up_and_drop_off_windows+ means the weekday's windows that
    # fit inside the hours are offered.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) from, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::SpecialOpeningHour>, nil].
    def get_listing_special_opening_hours(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::SpecialOpeningHour.parse(
        request(:get, "listings/#{listing_id}/special_opening_hours", params, nil)
      )
    end
  end
end
