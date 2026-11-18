# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A customer's store credit at one of the caller's listings.
  module DSL::StoreCredits
    # GET /customers/{customer_id}/store_credit
    # A customer's store credit balance usable at a listing (or its listing group, when the group shares
    # credit). A customer with no credit there yet answers a zero balance with a nil id. Raises
    # {UpwoofListings::Errors::ResourceNotFoundError} when the listing isn't the caller's or the customer isn't
    # one of its customers.
    # @param [String] customer_id A customer's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::StoreCreditAccount, nil].
    def get_customer_store_credit(customer_id:, listing_id:)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank?
      raise ArgumentError, 'Listing ID cannot be blank' if listing_id.blank?

      Resources::StoreCreditAccount.parse(
        request(:get, "customers/#{customer_id}/store_credit", { listing_id: listing_id }, nil)
      )
    end

    # GET /customers/{customer_id}/store_credit/transactions
    # The store credit ledger behind that balance, newest first.
    # @param [String] customer_id A customer's ID.
    # @param [String] listing_id One of the caller's listings.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::StoreCreditTransaction>, nil].
    def get_customer_store_credit_transactions(customer_id:, listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank?
      raise ArgumentError, 'Listing ID cannot be blank' if listing_id.blank?

      query = (params || {}).merge(listing_id: listing_id)
      Resources::StoreCreditTransaction.parse(
        request(:get, "customers/#{customer_id}/store_credit/transactions", query, nil)
      )
    end

    # POST /customers/{customer_id}/store_credit/adjustments
    # Add (positive amount_cents) or take back (negative) store credit, with a reason, at listing_id.
    # Owner/manager with two-factor authentication on only (else ClientError, HTTP 403). Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) for a zero or too-large amount, a blank or too-long
    # reason, or taking back more than the balance. The customer is notified and a
    # store_credit.balance_changed webhook is sent.
    # @param [String] customer_id A customer's ID.
    # @param [Hash] params listing_id, amount_cents, reason.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::StoreCreditTransaction, nil].
    def adjust_customer_store_credit(customer_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if customer_id.blank?

      Resources::StoreCreditTransaction.parse(
        request(:post, "customers/#{customer_id}/store_credit/adjustments", params)
      )
    end
  end
end
