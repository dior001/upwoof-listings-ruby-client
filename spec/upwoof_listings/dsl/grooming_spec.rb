# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::Grooming do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:grooming_url) { "#{base_url}/listings/1/grooming" }

  it 'lists services' do
    stub_request(:get, "#{grooming_url}/services?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 2, name: 'Bath', animal_types: ['Dog'] }].to_json, headers: json)

    services = client.get_listing_grooming_services(listing_id: 1)
    expect(services.first).to be_a(ServiceType)
    expect(services.first['animal_types']).to eq(['Dog'])
  end

  it 'lists groomers' do
    stub_request(:get, "#{grooming_url}/groomers?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 4, name: 'Sam', specialties: ['Poodles'] }].to_json, headers: json)

    expect(client.get_listing_groomers(listing_id: 1).first).to be_a(Groomer)
  end

  it 'gets open times, sending lists as key[]' do
    stub_request(:get, "#{grooming_url}/open_times")
      .with(query: { access_token: api_key, date: '2026-12-01', customer_id: '7', pet_ids: %w[3 4],
                     service_type_ids: ['2'] })
      .to_return(status: 200, body: { date: '2026-12-01', deposit_cents: 0,
                                      start_times: ['2026-12-01T09:00:00+13:00'] }.to_json, headers: json)

    times = client.get_listing_grooming_open_times(
      listing_id: 1, params: { date: '2026-12-01', customer_id: 7, pet_ids: [3, 4], service_type_ids: [2] }
    )
    expect(times).to be_a(GroomingOpenTimes)
    expect(times['start_times']).to eq(['2026-12-01T09:00:00+13:00'])
  end

  it 'books grooms' do
    params = { customer_id: 7, pet_ids: [3], service_type_ids: [2], starts_at: '2026-12-01T09:00:00+13:00' }
    stub_request(:post, "#{grooming_url}/appointments?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: [{ id: 11, status: 'scheduled', reservation_id: nil }].to_json, headers: json)

    appointments = client.create_listing_grooming_appointments(listing_id: 1, params: params)
    expect(appointments.first).to be_a(GroomingAppointment)
    expect(appointments.first['status']).to eq('scheduled')
  end

  it 'raises a ValidationError when the grooms would take a deposit' do
    message = "The listing takes a deposit on these grooms; the customer books them on the listing's UpWoof profile"
    stub_request(:post, "#{grooming_url}/appointments?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: [message] }.to_json, headers: json)

    expect { client.create_listing_grooming_appointments(listing_id: 1, params: { customer_id: 7 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
  end

  it 'raises a ClientError when the listing does not offer grooming online' do
    stub_request(:get, "#{grooming_url}/services?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.get_listing_grooming_services(listing_id: 1) }.to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_grooming_services(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_groomers(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_grooming_open_times(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_grooming_appointments(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
