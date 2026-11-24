# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A stay's care log: its feeding, medication, potty and note tasks. Any team member of the stay's listing (a stay or
  # task elsewhere raises {UpwoofListings::Errors::ResourceNotFoundError}). A task's outcome is ate_all, ate_some or
  # ate_none for a feeding and given or refused for a dose (nil while to do, or not recorded).
  module DSL::CareLogEntries
    # GET /reservations/{reservation_id}/care_log_entries
    # By scheduled_at, then id.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params (optional) date (YYYY-MM-DD, the listing's own day), entry_type (feeding, medication,
    #   potty, note), status (pending, completed), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::CareLogEntry>, nil].
    def get_reservation_care_log_entries(reservation_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::CareLogEntry.parse(request(:get, "reservations/#{reservation_id}/care_log_entries", params, nil))
    end

    # POST /care_log_entries/{id}/complete
    # Mark a task done. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when the task is already done,
    # the outcome doesn't fit its kind, or a refusal has no reason.
    # @param [String] id A care log entry's ID.
    # @param [Hash] params (optional) outcome, and for a medication dose_given and administration_notes (required
    #   when the outcome is refused).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CareLogEntry, nil].
    def complete_care_log_entry(id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::CareLogEntry.parse(request(:post, "care_log_entries/#{id}/complete", params || {}))
    end
  end
end
