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

    # POST /uw_listing_cms_apps
    # Create a CMS app.
    # @param [Hash] params CMS app attributes.
    # @return [UpwoofListings::Resources::UwListingCmsApp, nil].
    def create_uw_listing_cms_app(params:)
      Resources::UwListingCmsApp.parse(request(:post, 'uw_listing_cms_apps/', params))
    end

    # PUT /uw_listing_cms_apps/{id}
    # Update a CMS app.
    # @param [String] id A CMS app's ID.
    # @param [Hash] params CMS app attributes.
    # @return [UpwoofListings::Resources::UwListingCmsApp, nil].
    def update_uw_listing_cms_app(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::UwListingCmsApp.parse(request(:put, "uw_listing_cms_apps/#{id}", params))
    end

    # PATCH /uw_listing_cms_apps/{id}
    # Partially update a CMS app.
    # @param [String] id A CMS app's ID.
    # @param [Hash] params CMS app attributes.
    # @return [UpwoofListings::Resources::UwListingCmsApp, nil].
    def patch_uw_listing_cms_app(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::UwListingCmsApp.parse(request(:patch, "uw_listing_cms_apps/#{id}", params))
    end

    # DELETE /uw_listing_cms_apps/{id}
    # Delete a CMS app.
    # @param [String] id A CMS app's ID.
    # @return [Boolean].
    def delete_uw_listing_cms_app(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      request(:delete, "uw_listing_cms_apps/#{id}").status == 204
    end
  end
end
