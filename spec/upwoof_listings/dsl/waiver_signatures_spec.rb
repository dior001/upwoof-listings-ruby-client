require 'spec_helper'

describe UpwoofListings::DSL::WaiverSignatures do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_reservation_waiver_signature' do
    it 'returns the signed waiver' do
      stub_request(:get, "#{base_url}/reservations/1/waiver_signature?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 1, signature_data: 'Jane Doe', reservation_id: 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      signature = client.get_reservation_waiver_signature(reservation_id: 1)
      expect(signature).to be_a(WaiverSignature)
      expect(signature['signature_data']).to eq('Jane Doe')
    end

    it 'raises an ArgumentError when the reservation id is blank' do
      expect do
        client.get_reservation_waiver_signature(reservation_id: '')
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
