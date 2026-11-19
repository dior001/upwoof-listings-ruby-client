# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::AttendanceConfirmations do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:confirmation) do
    { id: 2, reservation_id: 3, status: 'pending', visit_on: '2026-11-20', visit_date: '2026-11-20',
      requested_at: '2026-11-19T08:00:00Z', responded_at: nil }
  end

  it 'lists a stay\'s requests' do
    stub_request(:get, "#{base_url}/reservations/3/attendance_confirmations?access_token=#{api_key}")
      .to_return(status: 200, body: [confirmation].to_json, headers: json)

    confirmations = client.get_reservation_attendance_confirmations(reservation_id: 3)
    expect(confirmations.first).to be_a(AttendanceConfirmation)
    expect(confirmations.first['visit_date']).to eq('2026-11-20')
  end

  it 'lists a listing\'s requests for a day and status' do
    url = "#{base_url}/listings/1/attendance_confirmations?access_token=#{api_key}&date=2026-11-20&status=declined"
    stub_request(:get, url)
      .to_return(status: 200, body: [confirmation.merge(status: 'declined')].to_json, headers: json)

    confirmations = client.get_listing_attendance_confirmations(listing_id: 1,
                                                                params: { date: '2026-11-20', status: 'declined' })
    expect(confirmations.first['status']).to eq('declined')
  end

  it 'raises a ClientError for a bad status' do
    stub_request(:get, "#{base_url}/listings/1/attendance_confirmations?access_token=#{api_key}&status=maybe")
      .to_return(status: 400, body: { error: 'status does not have a valid value' }.to_json, headers: json)

    expect { client.get_listing_attendance_confirmations(listing_id: 1, params: { status: 'maybe' }) }
      .to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_reservation_attendance_confirmations(reservation_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_attendance_confirmations(listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
