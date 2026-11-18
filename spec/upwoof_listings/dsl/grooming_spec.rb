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

  it 'books grooms held for a deposit, with return pages' do
    params = { customer_id: 7, pet_ids: [3], service_type_ids: [2], starts_at: '2026-12-01T09:00:00+13:00',
               success_url: 'https://example.com/paid?session={CHECKOUT_SESSION_ID}',
               cancel_url: 'https://example.com/cancelled' }
    stub_request(:post, "#{grooming_url}/appointments?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: [{ id: 11, kind: 'grooming', status: 'pending_payment', deposit_cents: 2000,
                                       deposit_status: 'pending',
                                       checkout_url: 'https://checkout.stripe.com/c/pay/cs_1' }].to_json,
                 headers: json)

    appointment = client.create_listing_grooming_appointments(listing_id: 1, params: params).first
    expect(appointment['status']).to eq('pending_payment')
    expect(appointment['checkout_url']).to eq('https://checkout.stripe.com/c/pay/cs_1')
  end

  it 'raises a ValidationError when the booking is refused' do
    message = "Stripe couldn't start the deposit payment; nothing was booked"
    stub_request(:post, "#{grooming_url}/appointments?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: [message] }.to_json, headers: json)

    expect { client.create_listing_grooming_appointments(listing_id: 1, params: { customer_id: 7 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
  end

  it 'lists grooms, sending ids as key[]' do
    stub_request(:get, "#{grooming_url}/appointments")
      .with(query: { access_token: api_key, status: 'pending_payment', ids: %w[11 12] })
      .to_return(status: 200, body: [{ id: 12, checkout_url: nil }].to_json, headers: json)

    appointments = client.get_listing_grooming_appointments(listing_id: 1,
                                                            params: { status: 'pending_payment', ids: [11, 12] })
    expect(appointments.first).to be_a(GroomingAppointment)
  end

  {
    'lessons' => %w[trainers get_listing_lesson_services get_listing_trainers get_listing_lesson_open_times
                    create_listing_lesson_appointments get_listing_lesson_appointments],
    'tours' => %w[hosts get_listing_tour_services get_listing_tour_hosts get_listing_tour_open_times
                  create_listing_tour_appointments get_listing_tour_appointments],
    'transports' => %w[drivers get_listing_transport_services get_listing_transport_drivers
                       get_listing_transport_open_times create_listing_transport_appointments
                       get_listing_transport_appointments]
  }.each do |kind_path, (providers_path, services, providers, open_times, create, index)|
    it "books #{kind_path}" do
      kind_url = "#{base_url}/listings/1/#{kind_path}"
      stub_request(:get, "#{kind_url}/services?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 2, kind: kind_path }].to_json, headers: json)
      stub_request(:get, "#{kind_url}/#{providers_path}?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 4, name: 'Sam' }].to_json, headers: json)
      stub_request(:get, "#{kind_url}/open_times")
        .with(query: { access_token: api_key, date: '2026-12-01' })
        .to_return(status: 200, body: { deposit_cents: 0, start_times: [] }.to_json, headers: json)
      stub_request(:post, "#{kind_url}/appointments?access_token=#{api_key}")
        .with(body: { customer_id: 7 }.to_json)
        .to_return(status: 201, body: [{ id: 11, status: 'scheduled' }].to_json, headers: json)
      stub_request(:get, "#{kind_url}/appointments?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 11, status: 'scheduled' }].to_json, headers: json)

      expect(client.public_send(services, listing_id: 1).first).to be_a(ServiceType)
      expect(client.public_send(providers, listing_id: 1).first).to be_a(Groomer)
      expect(client.public_send(open_times, listing_id: 1, params: { date: '2026-12-01' })).to be_a(GroomingOpenTimes)
      expect(client.public_send(create, listing_id: 1, params: { customer_id: 7 }).first).to be_a(GroomingAppointment)
      expect(client.public_send(index, listing_id: 1).first['status']).to eq('scheduled')
      expect { client.public_send(index, listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  it 'books a transport trip with a pickup address' do
    params = { customer_id: 7, pet_ids: [3], service_type_ids: [5], starts_at: '2026-12-01T09:00:00+13:00',
               pickup_street_address: '1 Queen St', pickup_city: 'Auckland' }
    stub_request(:post, "#{base_url}/listings/1/transports/appointments?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: [{ id: 11, kind: 'transport', transport_distance_km: 12.5 }].to_json,
                 headers: json)

    trip = client.create_listing_transport_appointments(listing_id: 1, params: params).first
    expect(trip['transport_distance_km']).to eq(12.5)
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
