# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Marking a listing's appointment (groom, private lesson, facility tour, pet transport trip) a no-show, as the
  # listing's board does: a scheduled or confirmed appointment whose start has passed. A deposit held for it is kept
  # (deposit_status forfeited; owner/manager only, else {UpwoofListings::Errors::ClientError}, HTTP 403); with none
  # held, the listing's no-show fee for that kind (if set) is billed on its own invoice. The customer is told. Raises
  # {UpwoofListings::Errors::ResourceNotFoundError} for an appointment that isn't the listing's of that kind and
  # {UpwoofListings::Errors::ValidationError} (HTTP 422) for one that can't be marked.
  module DSL::AppointmentNoShows
    # POST /listings/{id}/grooming/appointments/{visit_id}/no_show
    # @param [String] listing_id A listing's ID.
    # @param [String] appointment_id A groom's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingAppointment, nil].
    def mark_grooming_appointment_no_show(listing_id:, appointment_id:)
      mark_no_show(listing_id, 'grooming', appointment_id)
    end

    # POST /listings/{id}/lessons/appointments/{visit_id}/no_show
    # @param [String] listing_id A listing's ID.
    # @param [String] appointment_id A private lesson's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingAppointment, nil].
    def mark_lesson_no_show(listing_id:, appointment_id:)
      mark_no_show(listing_id, 'lessons', appointment_id)
    end

    # POST /listings/{id}/tours/appointments/{visit_id}/no_show
    # @param [String] listing_id A listing's ID.
    # @param [String] appointment_id A facility tour's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingAppointment, nil].
    def mark_tour_no_show(listing_id:, appointment_id:)
      mark_no_show(listing_id, 'tours', appointment_id)
    end

    # POST /listings/{id}/transports/appointments/{visit_id}/no_show
    # @param [String] listing_id A listing's ID.
    # @param [String] appointment_id A pet transport trip's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::GroomingAppointment, nil].
    def mark_transport_no_show(listing_id:, appointment_id:)
      mark_no_show(listing_id, 'transports', appointment_id)
    end

    private

    def mark_no_show(listing_id, kind_path, appointment_id)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || appointment_id.blank?

      Resources::GroomingAppointment.parse(
        request(:post, "listings/#{listing_id}/#{kind_path}/appointments/#{appointment_id}/no_show", {})
      )
    end
  end
end
