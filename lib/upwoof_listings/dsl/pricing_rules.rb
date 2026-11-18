# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's pricing rules. Owner/manager of the listing only (a staff member gets ClientError, HTTP 403);
  # a rule id that isn't the listing's raises {UpwoofListings::Errors::ResourceNotFoundError}.
  module DSL::PricingRules
    # GET /listings/{id}/pricing_rules
    # Highest priority first (priority desc, id asc).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::PricingRule>, nil].
    def get_listing_pricing_rules(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PricingRule.parse(request(:get, "listings/#{listing_id}/pricing_rules", params, nil))
    end

    # GET /listings/{id}/pricing_rules/{pricing_rule_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] pricing_rule_id A pricing rule's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PricingRule, nil].
    def get_listing_pricing_rule(listing_id:, pricing_rule_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || pricing_rule_id.blank?

      Resources::PricingRule.parse(request(:get, "listings/#{listing_id}/pricing_rules/#{pricing_rule_id}"))
    end

    # POST /listings/{id}/pricing_rules
    # name required. A rule needs at least one condition (animal_type_id, breed_ids, min_age_months,
    # max_age_months, customer_id, or neuter_status other than any_status); a refused rule raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params Pricing rule attributes.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PricingRule, nil].
    def create_listing_pricing_rule(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PricingRule.parse(request(:post, "listings/#{listing_id}/pricing_rules", params))
    end

    # PATCH /listings/{id}/pricing_rules/{pricing_rule_id}
    # Changes only the fields sent; send nil to clear an optional one.
    # @param [String] listing_id A listing's ID.
    # @param [String] pricing_rule_id A pricing rule's ID.
    # @param [Hash] params Pricing rule attributes.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PricingRule, nil].
    def patch_listing_pricing_rule(listing_id:, pricing_rule_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || pricing_rule_id.blank?

      Resources::PricingRule.parse(
        request(:patch, "listings/#{listing_id}/pricing_rules/#{pricing_rule_id}", params)
      )
    end

    # DELETE /listings/{id}/pricing_rules/{pricing_rule_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] pricing_rule_id A pricing rule's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_pricing_rule(listing_id:, pricing_rule_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || pricing_rule_id.blank?

      request(:delete, "listings/#{listing_id}/pricing_rules/#{pricing_rule_id}").status == 204
    end
  end
end
