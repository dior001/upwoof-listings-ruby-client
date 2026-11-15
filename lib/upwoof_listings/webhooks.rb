require 'openssl'
require 'upwoof_listings'

module UpwoofListings
  # Verifying the signatures on UpWoof's outbound webhook deliveries.
  #
  # Each delivery is signed with the subscription's secret, Base64(HMAC-SHA256(secret, message)):
  #
  # * X-Upwoof-Signature signs the raw request body alone. It proves who sent the delivery, not when.
  # * X-Upwoof-Timestamp is the send time in Unix seconds, and X-Upwoof-Timestamped-Signature signs
  #   "<timestamp>.<body>". Prefer {.verify_timestamped_signature}, which also rejects a delivery whose
  #   timestamp is outside the tolerance window, so a captured request can't be replayed later.
  #
  # Always pass the raw body exactly as received, before any JSON parsing.
  module Webhooks
    SIGNATURE_HEADER = 'X-Upwoof-Signature'
    TIMESTAMP_HEADER = 'X-Upwoof-Timestamp'
    TIMESTAMPED_SIGNATURE_HEADER = 'X-Upwoof-Timestamped-Signature'
    DELIVERY_ID_HEADER = 'X-Upwoof-Webhook-Id'
    DEFAULT_TOLERANCE_SECONDS = 300

    module_function

    # @param [String] message.
    # @param [String] secret.
    # @return [String] Base64(HMAC-SHA256(secret, message)).
    def compute_signature(message, secret)
      [OpenSSL::HMAC.digest('SHA256', secret.to_s, message.to_s)].pack('m0')
    end

    # True when signature (the X-Upwoof-Signature header) matches the raw payload.
    # @param [String] payload The raw request body.
    # @param [String] signature.
    # @param [String] secret The subscription's secret.
    # @return [Boolean].
    def verify_signature(payload:, signature:, secret:)
      return false if signature.blank? || secret.blank?

      OpenSSL.secure_compare(compute_signature(payload, secret), signature.to_s)
    end

    # True when signature (X-Upwoof-Timestamped-Signature) matches "<timestamp>.<payload>" and timestamp
    # (X-Upwoof-Timestamp) is within tolerance seconds of now, either side. A missing, malformed, stale or
    # future timestamp is rejected.
    # @param [String] payload The raw request body.
    # @param [String, Integer] timestamp.
    # @param [String] signature.
    # @param [String] secret The subscription's secret.
    # @param [Integer] tolerance Seconds (default 300).
    # @param [Time, Numeric] now (optional) The current time.
    # @return [Boolean].
    def verify_timestamped_signature(payload:, timestamp:, signature:, secret:,
                                     tolerance: DEFAULT_TOLERANCE_SECONDS, now: Time.now)
      return false if signature.blank? || secret.blank?

      raw_timestamp = timestamp.to_s.strip
      sent_at = Integer(raw_timestamp, 10, exception: false)
      return false if sent_at.nil? || (now.to_i - sent_at).abs > tolerance

      OpenSSL.secure_compare(compute_signature("#{raw_timestamp}.#{payload}", secret), signature.to_s)
    end
  end
end
