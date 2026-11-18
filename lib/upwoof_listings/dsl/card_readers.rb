# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's Stripe Terminal card readers and the in-person payments taken on them. Any team member of the
  # listing lists readers and takes payments; registering or removing a reader needs the owner/manager tier with
  # two-factor authentication on (ClientError, HTTP 403, otherwise).
  module DSL::CardReaders
    # GET /listings/{id}/card_readers
    # By label. status/online are as Stripe last reported them.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::CardReader>, nil].
    def get_listing_card_readers(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::CardReader.parse(request(:get, "listings/#{listing_id}/card_readers", params, nil))
    end

    # POST /listings/{id}/card_readers
    # Register a reader. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when Stripe refuses the code
    # or the listing can't take card payments.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params label and registration_code (shown on the reader), both required.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CardReader, nil].
    def create_listing_card_reader(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::CardReader.parse(request(:post, "listings/#{listing_id}/card_readers", params))
    end

    # DELETE /listings/{id}/card_readers/{reader_id}
    # Raises {UpwoofListings::Errors::ResourceNotFoundError} for an unknown reader and
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) when Stripe fails.
    # @param [String] listing_id A listing's ID.
    # @param [String] card_reader_id A card reader's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_card_reader(listing_id:, card_reader_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || card_reader_id.blank?

      request(:delete, "listings/#{listing_id}/card_readers/#{card_reader_id}").status == 204
    end

    # POST /listings/{id}/invoices/{invoice_id}/terminal_payment
    # Send an open invoice's balance to one of the listing's readers (status processing). Raises
    # {UpwoofListings::Errors::ResourceNotFoundError} when the invoice or reader isn't the listing's and
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) when there's nothing to collect, it's already on a
    # reader or paid, or Stripe refuses.
    # @param [String] listing_id A listing's ID.
    # @param [String] invoice_id An invoice's ID.
    # @param [String] card_reader_id A card reader's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def create_invoice_terminal_payment(listing_id:, invoice_id:, card_reader_id:)
      create_terminal_payment(listing_id, 'invoices', invoice_id, card_reader_id)
    end

    # GET /listings/{id}/invoices/{invoice_id}/terminal_payment
    # The invoice's reader payment, refreshed from Stripe while processing;
    # {UpwoofListings::Errors::ResourceNotFoundError} when none was started.
    # @param [String] listing_id A listing's ID.
    # @param [String] invoice_id An invoice's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def get_invoice_terminal_payment(listing_id:, invoice_id:)
      get_terminal_payment(listing_id, 'invoices', invoice_id)
    end

    # POST /listings/{id}/invoices/{invoice_id}/terminal_payment/cancel
    # Take the payment off the reader; {UpwoofListings::Errors::ValidationError} (HTTP 422) when Stripe can't.
    # @param [String] listing_id A listing's ID.
    # @param [String] invoice_id An invoice's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def cancel_invoice_terminal_payment(listing_id:, invoice_id:)
      cancel_terminal_payment(listing_id, 'invoices', invoice_id)
    end

    # POST /listings/{id}/retail_sales/{retail_sale_id}/terminal_payment
    # As create_invoice_terminal_payment, for a shop sale rung up as card_present.
    # @param [String] listing_id A listing's ID.
    # @param [String] retail_sale_id A shop sale's ID.
    # @param [String] card_reader_id A card reader's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def create_retail_sale_terminal_payment(listing_id:, retail_sale_id:, card_reader_id:)
      create_terminal_payment(listing_id, 'retail_sales', retail_sale_id, card_reader_id)
    end

    # GET /listings/{id}/retail_sales/{retail_sale_id}/terminal_payment
    # @param [String] listing_id A listing's ID.
    # @param [String] retail_sale_id A shop sale's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def get_retail_sale_terminal_payment(listing_id:, retail_sale_id:)
      get_terminal_payment(listing_id, 'retail_sales', retail_sale_id)
    end

    # POST /listings/{id}/retail_sales/{retail_sale_id}/terminal_payment/cancel
    # @param [String] listing_id A listing's ID.
    # @param [String] retail_sale_id A shop sale's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TerminalPayment, nil].
    def cancel_retail_sale_terminal_payment(listing_id:, retail_sale_id:)
      cancel_terminal_payment(listing_id, 'retail_sales', retail_sale_id)
    end

    private

    def create_terminal_payment(listing_id, payables, payable_id, card_reader_id)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || payable_id.blank? || card_reader_id.blank?

      Resources::TerminalPayment.parse(
        request(:post, "listings/#{listing_id}/#{payables}/#{payable_id}/terminal_payment",
                { card_reader_id: card_reader_id })
      )
    end

    def get_terminal_payment(listing_id, payables, payable_id)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || payable_id.blank?

      Resources::TerminalPayment.parse(
        request(:get, "listings/#{listing_id}/#{payables}/#{payable_id}/terminal_payment")
      )
    end

    def cancel_terminal_payment(listing_id, payables, payable_id)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || payable_id.blank?

      Resources::TerminalPayment.parse(
        request(:post, "listings/#{listing_id}/#{payables}/#{payable_id}/terminal_payment/cancel")
      )
    end
  end
end
