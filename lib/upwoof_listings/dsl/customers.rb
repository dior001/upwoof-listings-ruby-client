require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::Customers
    # GET /Customers
    # Get customers.
    # @return [Array, nil].
    def get_customers
      Resources::Customer.parse(request(:get, 'customers/', nil, nil))
    end

    # GET /Customer/{id}
    # Get a customer.
    # @param [String] id A customer's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Customer, nil].
    def get_customer(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::Customer.parse(request(:get, "customers/#{id}"))
    end
  end
end
