require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::UwListingCmsApps
    # GET /uw_listing_cms_apps
    # Get CMS apps.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_uw_listing_cms_apps(params: nil)
      Resources::UwListingCmsApp.parse(request(:get, 'uw_listing_cms_apps/', params, nil))
    end

    # GET /uw_listing_cms_apps/{id}
    # Get a CMS app.
    # @param [String] id A CMS app's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::UwListingCmsApp, nil].
    def get_uw_listing_cms_app(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::UwListingCmsApp.parse(request(:get, "uw_listing_cms_apps/#{id}"))
    end
  end
end
