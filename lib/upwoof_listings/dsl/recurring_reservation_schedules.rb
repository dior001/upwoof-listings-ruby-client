# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Recurring bookings: a customer's pets booked into one unit on the same weekdays every 1 to 4 weeks. Reading needs a
  # team member of the schedule's listing (a schedule elsewhere raises {UpwoofListings::Errors::ResourceNotFoundError});
  # creating, changing, stopping or skipping dates needs a team member allowed to manage the listing's recurring
  # bookings (else {UpwoofListings::Errors::ClientError}, HTTP 403). A schedule set up over the API confirms its dates
  # itself when they fit. weekdays are monday to sunday; interval is 1, 2, 3 or 4 (weeks).
  # A bad weekday or interval raises {UpwoofListings::Errors::ClientError} (HTTP 400).
  module DSL::RecurringReservationSchedules
    # GET /recurring_reservation_schedules
    # Schedules at the caller's listings, by id.
    # @param [Hash] params (optional) active, customer_id, listing_id, page, per_page.
    # @return [Array<UpwoofListings::Resources::RecurringReservationSchedule>, nil].
    def get_recurring_reservation_schedules(params: nil)
      Resources::RecurringReservationSchedule.parse(request(:get, 'recurring_reservation_schedules', params, nil))
    end

    # GET /recurring_reservation_schedules/{id}
    # @param [String] id A recurring reservation schedule's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def get_recurring_reservation_schedule(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::RecurringReservationSchedule.parse(request(:get, "recurring_reservation_schedules/#{id}"))
    end

    # POST /recurring_reservation_schedules
    # The first four weeks of dates are booked at once as reservations awaiting review, and the customer is emailed
    # one confirmation. Raises {UpwoofListings::Errors::ResourceNotFoundError} for a listing, customer or unit that
    # isn't among the caller's listings and {UpwoofListings::Errors::ValidationError} (HTTP 422) for pets that aren't
    # the customer household's active pets, a start in the past, and other refusals.
    # @param [Hash] params listing_id, customer_id, accommodation_id, pet_ids, weekdays and start_date (YYYY-MM-DD,
    #   today or later in the listing's zone) required; interval (default 1) and end_date optional.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def create_recurring_reservation_schedule(params:)
      Resources::RecurringReservationSchedule.parse(request(:post, 'recurring_reservation_schedules', params))
    end

    # PATCH /recurring_reservation_schedules/{id}
    # Changes only the fields sent. Upcoming dates the schedule no longer books that are awaiting review, or confirmed
    # themselves and haven't started, are cancelled, and new dates are booked at once. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) for a
    # refused change or a stopped schedule ("This recurring booking has been stopped").
    # @param [String] id A recurring reservation schedule's ID.
    # @param [Hash] params weekdays, interval, pet_ids, end_date (nil or blank clears it).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def patch_recurring_reservation_schedule(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::RecurringReservationSchedule.parse(request(:patch, "recurring_reservation_schedules/#{id}", params))
    end

    # POST /recurring_reservation_schedules/{id}/deactivate
    # Stop the schedule (active false). Its stays still awaiting review, and those that confirmed themselves and
    # haven't started, are cancelled free of charge; stays someone confirmed by hand are left. The customer is told.
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when it is already stopped.
    # @param [String] id A recurring reservation schedule's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def deactivate_recurring_reservation_schedule(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::RecurringReservationSchedule.parse(
        request(:post, "recurring_reservation_schedules/#{id}/deactivate", {})
      )
    end

    # POST /recurring_reservation_schedules/{id}/skipped_dates
    # Skip one date the schedule books within the next 90 days (the listing's zone); it is added to skipped_dates,
    # and a stay booked on it that is still awaiting review or confirmed itself is cancelled free of charge. Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) for any other date or a stopped schedule.
    # @param [String] id A recurring reservation schedule's ID.
    # @param [String, Date] date The date to skip (YYYY-MM-DD).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def skip_recurring_reservation_schedule_date(id:, date:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Date cannot be blank' if date.blank?

      Resources::RecurringReservationSchedule.parse(
        request(:post, "recurring_reservation_schedules/#{id}/skipped_dates", { date: date.to_s })
      )
    end

    # DELETE /recurring_reservation_schedules/{id}/skipped_dates/{skipped_date}
    # Restore a skipped date; it is booked again straight away when within the next four weeks. Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) when the date isn't skipped or the schedule is stopped.
    # @param [String] id A recurring reservation schedule's ID.
    # @param [String, Date] date The skipped date to restore (YYYY-MM-DD).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::RecurringReservationSchedule, nil].
    def restore_recurring_reservation_schedule_date(id:, date:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?
      raise ArgumentError, 'Date cannot be blank' if date.blank?

      Resources::RecurringReservationSchedule.parse(
        request(:delete, "recurring_reservation_schedules/#{id}/skipped_dates/#{date}")
      )
    end
  end
end
