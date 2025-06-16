require 'upwoof_listings'

module UpwoofListings
  module DSL
  end
end

require 'upwoof_listings/dsl/accommodations'
require 'upwoof_listings/dsl/credit_notes'
require 'upwoof_listings/dsl/customers'
require 'upwoof_listings/dsl/invoices'
require 'upwoof_listings/dsl/listings'
require 'upwoof_listings/dsl/orders'
require 'upwoof_listings/dsl/pets'
require 'upwoof_listings/dsl/reservations'
require 'upwoof_listings/dsl/users'
require 'upwoof_listings/utils'
require 'mime-types'

module UpwoofListings
  module DSL
    include Accommodations
    include CreditNotes
    include Customers
    include Invoices
    include Listings
    include Orders
    include Pets
    include Reservations
    include Users
    include Utils
  end
end
