require 'spec_helper'

describe UpwoofListings::Webhooks do
  let(:secret) { 'whsec_test' }
  let(:body) { '{"event_type":"reservation.confirmed","webhook_delivery_id":7,"data":{}}' }
  let(:timestamp) { '1763190000' }

  def sign(message, key = secret)
    [OpenSSL::HMAC.digest('SHA256', key, message)].pack('m0')
  end

  it 'names the headers and the default tolerance' do
    expect(described_class::SIGNATURE_HEADER).to eq('X-Upwoof-Signature')
    expect(described_class::TIMESTAMP_HEADER).to eq('X-Upwoof-Timestamp')
    expect(described_class::TIMESTAMPED_SIGNATURE_HEADER).to eq('X-Upwoof-Timestamped-Signature')
    expect(described_class::DEFAULT_TOLERANCE_SECONDS).to eq(300)
  end

  describe '.verify_signature' do
    it 'accepts the body signature' do
      expect(described_class.verify_signature(payload: body, signature: sign(body), secret:)).to be(true)
    end

    it 'rejects a tampered body, a wrong secret or a missing signature' do
      expect(described_class.verify_signature(payload: "#{body} ", signature: sign(body), secret:)).to be(false)
      expect(described_class.verify_signature(payload: body, signature: sign(body), secret: 'other')).to be(false)
      expect(described_class.verify_signature(payload: body, signature: nil, secret:)).to be(false)
    end
  end

  describe '.verify_timestamped_signature' do
    let(:signature) { sign("#{timestamp}.#{body}") }
    let(:sent_at) { Time.at(timestamp.to_i) }

    def verify(**overrides)
      described_class.verify_timestamped_signature(
        **{ payload: body, timestamp:, signature:, secret:, now: sent_at + 299 }.merge(overrides)
      )
    end

    it 'accepts a fresh delivery' do
      expect(verify).to be(true)
      expect(verify(timestamp: timestamp.to_i)).to be(true)
    end

    it 'rejects a stale or a future delivery' do
      expect(verify(now: sent_at + 301)).to be(false)
      expect(verify(now: sent_at - 301)).to be(false)
    end

    it 'honours a custom tolerance' do
      expect(verify(now: sent_at + 600, tolerance: 900)).to be(true)
    end

    it 'rejects a signature replayed under a newer timestamp' do
      expect(verify(timestamp: '1763190200', now: Time.at(1_763_190_200))).to be(false)
    end

    it 'rejects a missing or malformed timestamp, or a missing signature' do
      expect(verify(timestamp: nil)).to be(false)
      expect(verify(timestamp: 'yesterday')).to be(false)
      expect(verify(signature: '')).to be(false)
    end

    it 'uses the current time by default' do
      now = Time.now.to_i.to_s
      expect(
        described_class.verify_timestamped_signature(payload: body, timestamp: now,
                                                     signature: sign("#{now}.#{body}"), secret:)
      ).to be(true)
    end
  end
end
