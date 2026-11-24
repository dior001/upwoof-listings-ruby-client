# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's own notification wording. Owner/manager of the listing only (else ClientError, HTTP 403).
  module DSL::NotificationTemplates
    # GET /listings/{id}/notification_templates
    # Only the rows the listing has written (anything absent uses the default wording), ordered by
    # notification_key, channel, reservation_type.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::NotificationTemplateOverride>, nil].
    def get_listing_notification_templates(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::NotificationTemplateOverride.parse(
        request(:get, "listings/#{listing_id}/notification_templates", params, nil)
      )
    end

    # PUT /listings/{id}/notification_templates
    # Create or update one row; fields not sent are left unchanged. Raises
    # {UpwoofListings::Errors::ResourceNotFoundError} for a pair the listing isn't offered (sms only for
    # reservation_confirmed/upcoming_stay_reminder; grooming only for invoice_finalized/payment_received;
    # appointment_reminder, the day-before appointment reminder, is email and any_type only) and
    # {UpwoofListings::Errors::ValidationError} (HTTP 422) for an unknown {{tag}}, a length over the limit, or
    # switching off a notification that can't be.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params notification_key and channel (email, sms) required; reservation_type (any_type
    #   default, boarding, daycare, grooming), subject, body, enabled optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::NotificationTemplateOverride, nil].
    def update_listing_notification_template(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::NotificationTemplateOverride.parse(
        request(:put, "listings/#{listing_id}/notification_templates", params)
      )
    end

    # DELETE /listings/{id}/notification_templates
    # Go back to the default wording. Raises {UpwoofListings::Errors::ResourceNotFoundError} when there is no
    # such row.
    # @param [String] listing_id A listing's ID.
    # @param [String] notification_key The notification.
    # @param [String] channel email or sms.
    # @param [String] reservation_type (optional) any_type (default), boarding, daycare or grooming.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_notification_template(listing_id:, notification_key:, channel:, reservation_type: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?
      raise ArgumentError, 'Notification key and channel cannot be blank' if notification_key.blank? || channel.blank?

      query = { notification_key: notification_key, channel: channel, reservation_type: reservation_type }.compact
      request(:delete, "listings/#{listing_id}/notification_templates", query).status == 204
    end
  end
end
