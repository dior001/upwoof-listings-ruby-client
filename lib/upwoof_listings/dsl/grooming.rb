# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Booking a listing's appointments on a customer's behalf: grooms (grooming), private lessons (lessons), facility
  # tours (tours) and pet transport trips (transports). Any team member of the listing; every method but the
  # appointments lists raises ClientError (HTTP 403) when the listing doesn't offer that kind online, and every
  # method raises {UpwoofListings::Errors::ResourceNotFoundError} when the caller isn't on the listing's team.
  #
  # Open times: date (YYYY-MM-DD, the listing's zone), customer_id and service_type_ids required, pet_ids required
  # for every kind but tours (a tour has no pet), groomer_id optional (omit for any provider), and for grooms and
  # lessons pay_with_membership_credits (pay with the customer's household's membership credits, one a groom or
  # lesson, from plans whose credit_uses include grooming or lessons; no deposit is then taken). A deposit_cents above
  # 0 means the booking will be held for a deposit.
  #
  # Booking: the open-times params without date, plus starts_at (ISO 8601, one of the open start times); optional
  # success_url/cancel_url (full https addresses, at most 2000 characters; the success URL may carry Stripe's
  # {CHECKOUT_SESSION_ID}) are where the customer returns from a deposit payment. A booking that takes a deposit
  # comes back pending_payment (deposit_status pending) with a checkout_url to send the customer to; paying makes
  # it scheduled, an expired or failed payment cancels it. Raises {UpwoofListings::Errors::ValidationError}
  # (HTTP 422) for a bad pet, service or provider, too many appointments, a time that isn't open, a needed
  # evaluation a pet hasn't passed, a transport pickup address missing, not enough membership credits (no_credit),
  # or Stripe refusing to start the payment (nothing booked).
  #
  # Appointment lists: optional customer_id, ids, status (scheduled, confirmed, in_progress, completed, cancelled,
  # pending_payment, no_show: a booked appointment the customer never came to), page, per_page; newest start first,
  # checkout_url always nil.
  module DSL::Grooming
    # GET /listings/{id}/grooming/services
    # Active grooming services bookable online, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ServiceType>, nil].
    def get_listing_grooming_services(listing_id:, params: nil)
      Resources::ServiceType.parse(appointment_kind_request(:get, listing_id, 'grooming', 'services', params))
    end

    # GET /listings/{id}/grooming/groomers
    # Active groomers taking grooms, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Groomer>, nil].
    def get_listing_groomers(listing_id:, params: nil)
      Resources::Groomer.parse(appointment_kind_request(:get, listing_id, 'grooming', 'groomers', params))
    end

    # GET /listings/{id}/grooming/open_times
    # pay_with_membership_credits optional. Raises {UpwoofListings::Errors::ResourceNotFoundError} for a customer that
    # isn't the listing's and {UpwoofListings::Errors::ValidationError} (HTTP 422) for a bad pet, service or groomer,
    # too many grooms, a service needing an evaluation a pet hasn't passed, or not enough membership credits.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingOpenTimes, nil].
    def get_listing_grooming_open_times(listing_id:, params:)
      Resources::GroomingOpenTimes.parse(appointment_kind_request(:get, listing_id, 'grooming', 'open_times', params))
    end

    # POST /listings/{id}/grooming/appointments
    # Book one groom per pet per service; see the module comment.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def create_listing_grooming_appointments(listing_id:, params:)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:post, listing_id, 'grooming', 'appointments', params)
      )
    end

    # GET /listings/{id}/grooming/appointments
    # The listing's grooms; see the module comment for the filters.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) customer_id, ids, status, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def get_listing_grooming_appointments(listing_id:, params: nil)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:get, listing_id, 'grooming', 'appointments', params)
      )
    end

    # GET /listings/{id}/lessons/services
    # Active private lesson services bookable online, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ServiceType>, nil].
    def get_listing_lesson_services(listing_id:, params: nil)
      Resources::ServiceType.parse(appointment_kind_request(:get, listing_id, 'lessons', 'services', params))
    end

    # GET /listings/{id}/lessons/trainers
    # Active trainers taking private lessons, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Groomer>, nil].
    def get_listing_trainers(listing_id:, params: nil)
      Resources::Groomer.parse(appointment_kind_request(:get, listing_id, 'lessons', 'trainers', params))
    end

    # GET /listings/{id}/lessons/open_times
    # See the module comment; pay_with_membership_credits optional.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingOpenTimes, nil].
    def get_listing_lesson_open_times(listing_id:, params:)
      Resources::GroomingOpenTimes.parse(appointment_kind_request(:get, listing_id, 'lessons', 'open_times', params))
    end

    # POST /listings/{id}/lessons/appointments
    # Book private lessons; see the module comment.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def create_listing_lesson_appointments(listing_id:, params:)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:post, listing_id, 'lessons', 'appointments', params)
      )
    end

    # GET /listings/{id}/lessons/appointments
    # The listing's private lessons; see the module comment for the filters.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) customer_id, ids, status, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def get_listing_lesson_appointments(listing_id:, params: nil)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:get, listing_id, 'lessons', 'appointments', params)
      )
    end

    # GET /listings/{id}/tours/services
    # Active tour services bookable online, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ServiceType>, nil].
    def get_listing_tour_services(listing_id:, params: nil)
      Resources::ServiceType.parse(appointment_kind_request(:get, listing_id, 'tours', 'services', params))
    end

    # GET /listings/{id}/tours/hosts
    # Active tour hosts, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Groomer>, nil].
    def get_listing_tour_hosts(listing_id:, params: nil)
      Resources::Groomer.parse(appointment_kind_request(:get, listing_id, 'tours', 'hosts', params))
    end

    # GET /listings/{id}/tours/open_times
    # See the module comment; no pet_ids (a tour has no pet).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingOpenTimes, nil].
    def get_listing_tour_open_times(listing_id:, params:)
      Resources::GroomingOpenTimes.parse(appointment_kind_request(:get, listing_id, 'tours', 'open_times', params))
    end

    # POST /listings/{id}/tours/appointments
    # Book facility tours (no pet_ids; the appointment's pet_id is nil); see the module comment.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def create_listing_tour_appointments(listing_id:, params:)
      Resources::GroomingAppointment.parse(appointment_kind_request(:post, listing_id, 'tours', 'appointments', params))
    end

    # GET /listings/{id}/tours/appointments
    # The listing's facility tours; see the module comment for the filters.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) customer_id, ids, status, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def get_listing_tour_appointments(listing_id:, params: nil)
      Resources::GroomingAppointment.parse(appointment_kind_request(:get, listing_id, 'tours', 'appointments', params))
    end

    # GET /listings/{id}/transports/services
    # Active pet transport services bookable online, by name (with per_km_surcharge_cents).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::ServiceType>, nil].
    def get_listing_transport_services(listing_id:, params: nil)
      Resources::ServiceType.parse(appointment_kind_request(:get, listing_id, 'transports', 'services', params))
    end

    # GET /listings/{id}/transports/drivers
    # Active drivers, by name.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Groomer>, nil].
    def get_listing_transport_drivers(listing_id:, params: nil)
      Resources::Groomer.parse(appointment_kind_request(:get, listing_id, 'transports', 'drivers', params))
    end

    # GET /listings/{id}/transports/open_times
    # See the module comment.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See the module comment.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingOpenTimes, nil].
    def get_listing_transport_open_times(listing_id:, params:)
      Resources::GroomingOpenTimes.parse(
        appointment_kind_request(:get, listing_id, 'transports', 'open_times', params)
      )
    end

    # POST /listings/{id}/transports/appointments
    # Book one pet transport trip; see the module comment. Also takes a pickup (pickup_address_id, one of the
    # customer's saved addresses, or typed pickup_street_address, pickup_city, pickup_apartment_or_suite,
    # pickup_state_or_province, pickup_zip_or_postal_code, pickup_country_code; typed wins) and an optional
    # drop-off (dropoff_*, the same six; blank means the listing).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params See above.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def create_listing_transport_appointments(listing_id:, params:)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:post, listing_id, 'transports', 'appointments', params)
      )
    end

    # GET /listings/{id}/transports/appointments
    # The listing's pet transport trips; see the module comment for the filters.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) customer_id, ids, status, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::GroomingAppointment>, nil].
    def get_listing_transport_appointments(listing_id:, params: nil)
      Resources::GroomingAppointment.parse(
        appointment_kind_request(:get, listing_id, 'transports', 'appointments', params)
      )
    end

    private

    def appointment_kind_request(method, listing_id, kind_path, action, params)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      path = "listings/#{listing_id}/#{kind_path}/#{action}"
      method == :get ? request(:get, path, params, nil) : request(method, path, params)
    end
  end
end
