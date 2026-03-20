require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Invoices
    # GET /Invoices
    # Get invoices.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_invoices(params: nil)
      Resources::Invoice.parse(request(:get, 'invoices/', params, nil))
    end

    # GET /Invoice/{id}
    # Get an invoice.
    # @param [String] id An invoice's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Invoice, nil].
    def get_invoice(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Invoice.parse(request(:get, "invoices/#{id}"))
    end

    # POST /invoices
    # Create an invoice.
    # @param [Hash] params Invoice attributes.
    # @return [UpwoofListings::Resources::Invoice, nil].
    def create_invoice(params:)
      Resources::Invoice.parse(request(:post, 'invoices/', params))
    end

    # PUT /invoices/{id}
    # Update an invoice.
    # @param [String] id An invoice's ID.
    # @param [Hash] params Invoice attributes.
    # @return [UpwoofListings::Resources::Invoice, nil].
    def update_invoice(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Invoice.parse(request(:put, "invoices/#{id}", params))
    end

    # PATCH /invoices/{id}
    # Partially update an invoice.
    # @param [String] id An invoice's ID.
    # @param [Hash] params Invoice attributes.
    # @return [UpwoofListings::Resources::Invoice, nil].
    def patch_invoice(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Invoice.parse(request(:patch, "invoices/#{id}", params))
    end

    # POST /invoices/{id}/pay_out_of_band
    # Pay an invoice out of band.
    # @param [String] id An invoice's ID.
    # @return [UpwoofListings::Resources::Invoice, nil].
    def pay_invoice_out_of_band(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Invoice.parse(request(:post, "invoices/#{id}/pay_out_of_band"))
    end
  end
end
