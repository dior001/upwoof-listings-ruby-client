require 'upwoof_listings'

module UpwoofListings
  module DSL
  end
end

require 'upwoof_listings/dsl/listings'
require 'upwoof_listings/utils'
require 'mime-types'

module UpwoofListings
  module DSL
    include Listings
    include Utils
  end
end
