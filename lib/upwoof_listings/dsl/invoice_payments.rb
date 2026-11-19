# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # The parts an invoice was paid in (split payments). Listing them is open to any team member of the invoice's
  # listing; recording and refunding a part need owner/manager with two-factor authentication on (else
  # {UpwoofListings::Errors::ClientError}, HTTP 403, as for an invoice that isn't open). An invoice or part that isn't
  # reachable raises {UpwoofListings::Errors::ResourceNotFoundError}. A part's tender is card_online, card_reader,
  # cash, check or store_credit.
  module DSL::InvoicePayments
    # GET /invoices/{id}/payments
    # Oldest first.
    # @param [String] invoice_id An invoice's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::InvoicePayment>, nil].
    def get_invoice_payments(invoice_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if invoice_id.blank?

      Resources::InvoicePayment.parse(request(:get, "invoices/#{invoice_id}/payments", params, nil))
    end

    # POST /invoices/{id}/payments
    # Records part of an open invoice taken in cash or by check. Raises {UpwoofListings::Errors::ValidationError}
    # (HTTP 422) for a bad amount, or while a card payment is on a reader or the customer is paying online.
    # @param [String] invoice_id An invoice's ID.
    # @param [Hash] params tender required (cash or check); amount_cents optional (default: everything the invoice
    #   still owes).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::InvoicePayment, nil].
    def create_invoice_payment(invoice_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if invoice_id.blank?

      Resources::InvoicePayment.parse(request(:post, "invoices/#{invoice_id}/payments", params))
    end

    # POST /invoices/{id}/payments/{payment_id}/refund
    # Refunds one part while the invoice is still open (cash or a check out of the till, a card reader part to its
    # card, a store credit part given back whole); what is refunded is owed again. Returns the part after the refund.
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when the part isn't refundable, the amount is bad, a
    # card payment is in progress, store credit isn't refunded whole or Stripe refused. Refund a paid invoice's part
    # with create_credit_note and invoice_payment_id instead.
    # @param [String] invoice_id An invoice's ID.
    # @param [String] payment_id The part's ID.
    # @param [Hash] params (optional) amount_cents (default: everything left to refund on the part).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::InvoicePayment, nil].
    def refund_invoice_payment(invoice_id:, payment_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if invoice_id.blank? || payment_id.blank?

      Resources::InvoicePayment.parse(request(:post, "invoices/#{invoice_id}/payments/#{payment_id}/refund", params))
    end
  end
end
