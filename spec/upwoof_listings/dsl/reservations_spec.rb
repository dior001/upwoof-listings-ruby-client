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

  describe 'a refused date change' do
    let(:refusal) do
      { status: 422, body: { errors: ['Accommodation is not available for those dates'] }.to_json,
        headers: { 'Content-Type' => 'application/json' } }
    end

    it 'raises a ValidationError carrying the API errors from #update_reservation' do
      stub_request(:put, "#{base_url}/reservations/2?access_token=#{api_key}").to_return(refusal)

      expect { client.update_reservation(id: 2, params: { when_reservation_finish: '2026-12-20' }) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |error|
          expect(error.errors).to eq(['Accommodation is not available for those dates'])
        }
    end

    it 'raises a ValidationError from #patch_reservation' do
      stub_request(:patch, "#{base_url}/reservations/2?access_token=#{api_key}").to_return(refusal)

      expect { client.patch_reservation(id: 2, params: { when_reservation_finish: '2026-12-20' }) }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end
  end

  describe '#cancel_reservation' do
    it 'cancels a reservation, applying the listing\'s own policy by default' do
      stub_request(:post, "#{base_url}/reservations/2/cancel?access_token=#{api_key}")
        .with(body: { reason: 'Customer called to cancel' }.to_json)
        .to_return(status: 200, body: { id: 2, workflow_state: 'canceled_without_charge' }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      reservation = client.cancel_reservation(id: 2, reason: 'Customer called to cancel')
      expect(reservation).to be_a(Reservation)
      expect(reservation['workflow_state']).to eq('canceled_without_charge')
    end

    it 'sends mode when given' do
      stub_request(:post, "#{base_url}/reservations/2/cancel?access_token=#{api_key}")
        .with(body: { reason: 'Goodwill refund', mode: 'full_refund' }.to_json)
        .to_return(status: 200, body: { id: 2, workflow_state: 'canceled_without_charge' }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      reservation = client.cancel_reservation(id: 2, reason: 'Goodwill refund', mode: 'full_refund')
      expect(reservation).to be_a(Reservation)
    end

    it 'raises ArgumentError without an id' do
      expect { client.cancel_reservation(id: nil, reason: 'Why') }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError without a reason' do
      expect { client.cancel_reservation(id: 2, reason: nil) }.to raise_error(ArgumentError)
    end

    it 'raises a ValidationError when the cancellation itself is refused' do
      stub_request(:post, "#{base_url}/reservations/2/cancel?access_token=#{api_key}")
        .to_return(status: 422, body: { errors: ['cannot cancel'] }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      expect { client.cancel_reservation(id: 2, reason: 'Why') }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |error|
          expect(error.errors).to eq(['cannot cancel'])
        }
    end
  end

  # DELETE /reservations/{id} was removed from the API (there is no way to delete a reservation):
  # confirm the client doesn't offer a method that would only ever 404.
  it 'has no #delete_reservation method' do
    expect(client).not_to respond_to(:delete_reservation)
  end
end
