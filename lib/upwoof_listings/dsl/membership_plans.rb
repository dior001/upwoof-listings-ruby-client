# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's membership plans, read only (team members of the listing; else ClientError, HTTP 403).
  module DSL::MembershipPlans
    # GET /listings/{id}/membership_plans
    # Active and inactive plans, by name then id.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::MembershipPlan>, nil].
    def get_listing_membership_plans(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::MembershipPlan.parse(request(:get, "listings/#{listing_id}/membership_plans", params, nil))
    end

    # GET /listings/{id}/membership_plans/{membership_plan_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] membership_plan_id A membership plan's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::MembershipPlan, nil].
    def get_listing_membership_plan(listing_id:, membership_plan_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || membership_plan_id.blank?

      Resources::MembershipPlan.parse(
        request(:get, "listings/#{listing_id}/membership_plans/#{membership_plan_id}")
      )
    end
  end
end
