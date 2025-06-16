require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Invoices
    # GET /Invoices
    # Get invoices.
    # @return [Array, nil].
    def get_invoices
      Resources::Invoice.parse(request(:get, 'invoices/', nil, nil))
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
  end
end
