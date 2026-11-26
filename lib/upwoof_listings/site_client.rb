# frozen_string_literal: true

require 'faraday'
require 'json'
require 'upwoof_listings'
require 'upwoof_listings/errors'
require 'upwoof_listings/resources'
require 'upwoof_listings/utils'

module UpwoofListings
  # The site API (/api/v1/site): what a listing's own UpWoof website reads and sends. Authenticated by the website's
  # site token (UPWOOF_SITE_TOKEN), always sent as `Authorization: Bearer <token>`, never in the URL. Each token
  # sees one listing. Errors are `{ error, message }`: a refusal raises ValidationError (its `body['error']` the code),
  # a bad token ClientError (401), too many requests ClientError (429).
  class SiteClient
    HEADERS = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }.freeze

    def initialize(site_token, url = UpwoofListings.url)
      raise ArgumentError, 'Site token cannot be blank' if site_token.blank?

      @site_token = site_token
      @url = url
      @connection = Faraday.new { |builder| builder.adapter Faraday.default_adapter }
    end

    # rubocop:disable Naming/AccessorMethodName -- get_ names, as the main client's

    # GET /site: theme, palette, hosts, status and booking switch.
    # @return [UpwoofListings::Resources::SiteConfig].
    def get_site_config
      Resources::SiteConfig.parse(request(:get, 'site'))
    end

    # GET /site/listing: the listing's public facts.
    # @return [UpwoofListings::Resources::SiteListing].
    def get_site_listing
      Resources::SiteListing.parse(request(:get, 'site/listing'))
    end

    # GET /site/accommodations: the units a customer could book online.
    # @return [Array<UpwoofListings::Resources::SiteAccommodation>].
    def get_site_accommodations
      Resources::SiteAccommodation.parse(request(:get, 'site/accommodations'))
    end

    # rubocop:enable Naming/AccessorMethodName

    # GET /site/reviews: a page of published reviews (`reviews`, `page`, `total_pages`).
    # @param [Integer] page (optional) From 1.
    # @return [UpwoofListings::Resources::SiteReviewPage].
    def get_site_reviews(page: nil)
      Resources::SiteReviewPage.parse(request(:get, 'site/reviews', { page: page }))
    end

    # GET /site/availability: which units take a stay, and what each costs.
    # @param [Hash] params check_in, check_out (YYYY-MM-DD), dogs, cats.
    # @return [UpwoofListings::Resources::SiteAvailability].
    def get_site_availability(params:)
      Resources::SiteAvailability.parse(request(:get, 'site/availability', params))
    end

    # POST /site/booking_requests: a booking request, awaiting the listing's review.
    # @param [Hash] params check_in, check_out, accommodation_id, drop_off_window_id, pick_up_window_id, owner,
    #   pets, notes, accepted_terms.
    # @param [String] visitor_ip (optional) The visitor's address, sent as X-Visitor-IP.
    # @return [UpwoofListings::Resources::SiteBookingRequest].
    def create_site_booking_request(params:, visitor_ip: nil)
      Resources::SiteBookingRequest.parse(request(:post, 'site/booking_requests', params, visitor_ip))
    end

    # POST /site/inquiries: a question to the listing.
    # @param [Hash] params first_name, last_name, email, phone, message, pet_name, species.
    # @param [String] visitor_ip (optional) The visitor's address, sent as X-Visitor-IP.
    # @return [UpwoofListings::Resources::SiteInquiry].
    def create_site_inquiry(params:, visitor_ip: nil)
      Resources::SiteInquiry.parse(request(:post, 'site/inquiries', params, visitor_ip))
    end

    private

    def request(method, path, query = {}, visitor_ip = nil)
      headers = HEADERS.merge('Authorization' => "Bearer #{@site_token}")
      headers['X-Visitor-IP'] = visitor_ip if visitor_ip.present?
      response = if method == :get
                   url = Utils::UrlHelper.build_url(path: "#{@url}#{path}", params: query.dup)
                   @connection.run_request(:get, url, nil, headers)
                 else
                   @connection.run_request(method, "#{@url}#{path}", JSON.generate(query), headers)
                 end
      check(response)
    end

    def check(response)
      case response.status.to_i
      when 200..299 then response
      when 404 then raise Errors::ResourceNotFoundError.new(response: response)
      when 422 then raise Errors::ValidationError.new(response: response)
      else raise Errors::ClientError.new(response: response)
      end
    end
  end
end
