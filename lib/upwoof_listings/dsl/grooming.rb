# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Booking a listing's grooms online on a customer's behalf. Any team member of the listing; every method raises
  # ClientError (HTTP 403) when the listing doesn't offer grooming online and
  # {UpwoofListings::Errors::ResourceNotFoundError} when the caller isn't on the listing's team.
  module DSL::Grooming
    # GET /listings/{id}/grooming/services
    # Active grooming services bookable online, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ServiceType>, nil].
    def get_listing_grooming_services(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::ServiceType.parse(request(:get, "listings/#{listing_id}/grooming/services", params, nil))
    end

    # GET /listings/{id}/grooming/groomers
    # Active groomers taking grooms, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Groomer>, nil].
    def get_listing_groomers(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::Groomer.parse(request(:get, "listings/#{listing_id}/grooming/groomers", params, nil))
    end

    # GET /listings/{id}/grooming/open_times
    # A deposit_cents above 0 means create_listing_grooming_appointments will refuse these grooms. Raises
    # {UpwoofListings::Errors::ResourceNotFoundError} for a customer that isn't the listing's and
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) for a bad pet, service or groomer, more than 6 grooms,
    # or a service needing an evaluation a pet hasn't passed.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params date (YYYY-MM-DD, the listing's zone), customer_id, pet_ids, service_type_ids
    #   required; groomer_id optional (omit for any groomer).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingOpenTimes, nil].
    def get_listing_grooming_open_times(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::GroomingOpenTimes.parse(request(:get, "listings/#{listing_id}/grooming/open_times", params, nil))
    end

    # POST /listings/{id}/grooming/appointments
    # Book one groom per pet per service. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) as
    # get_listing_grooming_open_times does, when the time isn't open, or when the grooms would take a deposit
    # (the customer books those on the listing's UpWoof profile).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params customer_id, pet_ids, service_type_ids, starts_at (ISO 8601, one of the open start
    #   times) required; groomer_id optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def create_listing_grooming_appointments(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::GroomingAppointment.parse(request(:post, "listings/#{listing_id}/grooming/appointments", params))
    end
  end
end
