require 'spec_helper'

describe UpwoofListings::DSL::Reservations do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_reservations' do
    it 'returns an array of reservations' do
      stub_request(:get, "#{base_url}/reservations/?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, reservation_number: 'RES-1' }].to_json, headers: { 'Content-Type' => 'application/json' })

      reservations = client.get_reservations
      expect(reservations).to be_a(Array)
      expect(reservations.first).to be_a(Reservation)
      expect(reservations.first['reservation_number']).to eq('RES-1')
    end
  end

  describe '#get_reservation' do
    it 'returns a reservation' do
      stub_request(:get, "#{base_url}/reservations/1?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 1, reservation_number: 'RES-1' }.to_json, headers: { 'Content-Type' => 'application/json' })

      reservation = client.get_reservation(id: 1)
      expect(reservation).to be_a(Reservation)
      expect(reservation['reservation_number']).to eq('RES-1')
    end
  end

  describe '#create_reservation' do
    it 'creates a reservation' do
      params = { pet_id: 1, start_date: '2026-04-01', end_date: '2026-04-05' }
      stub_request(:post, "#{base_url}/reservations/?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, reservation_number: 'RES-2' }.to_json, headers: { 'Content-Type' => 'application/json' })

      reservation = client.create_reservation(params: params)
      expect(reservation).to be_a(Reservation)
    end
  end

  describe '#update_reservation' do
    it 'updates a reservation' do
      params = { end_date: '2026-04-06' }
      stub_request(:put, "#{base_url}/reservations/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, end_date: '2026-04-06' }.to_json, headers: { 'Content-Type' => 'application/json' })

      reservation = client.update_reservation(id: 2, params: params)
      expect(reservation).to be_a(Reservation)
    end
  end

  describe '#patch_reservation' do
    it 'partially updates a reservation' do
      params = { end_date: '2026-04-07' }
      stub_request(:patch, "#{base_url}/reservations/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, end_date: '2026-04-07' }.to_json, headers: { 'Content-Type' => 'application/json' })

      reservation = client.patch_reservation(id: 2, params: params)
      expect(reservation).to be_a(Reservation)
    end
  end

  describe '#delete_reservation' do
    it 'deletes a reservation' do
      stub_request(:delete, "#{base_url}/reservations/2?access_token=#{api_key}")
        .to_return(status: 204)

      expect(client.delete_reservation(id: 2)).to be true
    end
  end
end
