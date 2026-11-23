# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::RecurringReservationSchedules do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:schedules_url) { "#{base_url}/recurring_reservation_schedules" }
  let(:schedule) do
    { id: 4, listing_id: 1, customer_id: 7, accommodation_id: 9, pet_ids: [3], active: true,
      weekdays: %w[monday friday], interval: 1, start_date: '2026-12-01', end_date: nil, skipped_dates: [],
      recurrence_description: 'Weekly on Mondays and Fridays', created_at: '2026-11-23T08:00:00Z',
      updated_at: '2026-11-23T08:00:00Z' }
  end

  it 'lists schedules' do
    stub_request(:get, "#{schedules_url}?access_token=#{api_key}&active=true&listing_id=1")
      .to_return(status: 200, body: [schedule].to_json, headers: json)

    schedules = client.get_recurring_reservation_schedules(params: { listing_id: 1, active: true })
    expect(schedules.first).to be_a(RecurringReservationSchedule)
    expect(schedules.first['weekdays']).to eq(%w[monday friday])
  end

  it 'gets a schedule' do
    stub_request(:get, "#{schedules_url}/4?access_token=#{api_key}")
      .to_return(status: 200, body: schedule.to_json, headers: json)

    expect(client.get_recurring_reservation_schedule(id: 4)['recurrence_description'])
      .to eq('Weekly on Mondays and Fridays')
  end

  it 'raises a ResourceNotFoundError for a schedule elsewhere' do
    stub_request(:get, "#{schedules_url}/5?access_token=#{api_key}").to_return(status: 404, body: '{}')

    expect { client.get_recurring_reservation_schedule(id: 5) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'creates a schedule' do
    params = { listing_id: 1, customer_id: 7, accommodation_id: 9, pet_ids: [3], weekdays: %w[monday friday],
               start_date: '2026-12-01', interval: 2 }
    stub_request(:post, "#{schedules_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: schedule.merge(interval: 2).to_json, headers: json)

    expect(client.create_recurring_reservation_schedule(params: params)['interval']).to eq(2)
  end

  it 'raises a ValidationError for a refused schedule' do
    stub_request(:post, "#{schedules_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['Start date must be today or later'] }.to_json, headers: json)

    expect { client.create_recurring_reservation_schedule(params: { listing_id: 1 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error|
        expect(error.errors).to eq(['Start date must be today or later'])
      }
  end

  it 'raises a ClientError when the caller may not manage the listing' do
    stub_request(:post, "#{schedules_url}?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.create_recurring_reservation_schedule(params: { listing_id: 1 }) }
      .to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'changes a schedule, clearing its end date' do
    stub_request(:patch, "#{schedules_url}/4?access_token=#{api_key}")
      .with(body: { weekdays: ['tuesday'], end_date: nil }.to_json)
      .to_return(status: 200, body: schedule.to_json, headers: json)

    changed = client.patch_recurring_reservation_schedule(id: 4, params: { weekdays: ['tuesday'], end_date: nil })
    expect(changed['end_date']).to be_nil
  end

  it 'raises a ValidationError for a stopped schedule' do
    message = 'This recurring booking has been stopped'
    stub_request(:patch, "#{schedules_url}/4?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'unprocessable', message: message }.to_json, headers: json)

    expect { client.patch_recurring_reservation_schedule(id: 4, params: { interval: 3 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_recurring_reservation_schedule(id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_recurring_reservation_schedule(id: nil, params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end

describe 'batch 30 API changes' do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  it 'raises a ValidationError naming pet_has_history for a pet with history' do
    body = { error: 'pet_has_history', message: 'Biscuit has stays; deactivate it instead' }
    stub_request(:delete, "#{base_url}/pets/3?access_token=#{api_key}")
      .to_return(status: 422, body: body.to_json, headers: json)

    expect { client.delete_pet(id: 3) }.to raise_error(UpwoofListings::Errors::ValidationError) { |error|
      expect(error.body['error']).to eq('pet_has_history')
      expect(error.errors).to eq(['Biscuit has stays; deactivate it instead'])
    }
  end

  it 'raises a ClientError when a staff member deletes an accommodation' do
    stub_request(:delete, "#{base_url}/accommodations/9?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.delete_accommodation(id: 9) }.to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'reads a gift card invoice payment part' do
    stub_request(:get, "#{base_url}/invoices/5/payments?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 8, tender: 'gift_card', reported_to_stripe: true }].to_json, headers: json)

    expect(client.get_invoice_payments(invoice_id: 5).first['tender']).to eq('gift_card')
  end

  it 'filters appointments by no_show' do
    stub_request(:get, "#{base_url}/listings/1/grooming/appointments?access_token=#{api_key}&status=no_show")
      .to_return(status: 200, body: [{ id: 12, status: 'no_show' }].to_json, headers: json)

    appointments = client.get_listing_grooming_appointments(listing_id: 1, params: { status: 'no_show' })
    expect(appointments.first['status']).to eq('no_show')
  end

  it 'books grooms with membership credits' do
    params = { customer_id: 7, pet_ids: [3], service_type_ids: [2], starts_at: '2026-12-01T09:00:00+13:00',
               pay_with_membership_credits: true }
    stub_request(:post, "#{base_url}/listings/1/grooming/appointments?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: [{ id: 11, status: 'scheduled', deposit_cents: 0 }].to_json, headers: json)

    expect(client.create_listing_grooming_appointments(listing_id: 1, params: params).first['deposit_cents']).to eq(0)
  end

  it 'raises a ValidationError when the household has too few credits' do
    message = "The customer's household hasn't enough membership credits for these appointments"
    stub_request(:get, "#{base_url}/listings/1/grooming/open_times?access_token=#{api_key}" \
                       '&pay_with_membership_credits=true')
      .to_return(status: 422, body: { error: 'no_credit', message: message }.to_json, headers: json)

    expect { client.get_listing_grooming_open_times(listing_id: 1, params: { pay_with_membership_credits: true }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
  end

  it 'reads a membership plan\'s credit_uses' do
    plan = { id: 2, credit_uses: %w[stays grooming], credit_use: 'stays', credits_cover_lessons: false }
    stub_request(:get, "#{base_url}/listings/1/membership_plans/2?access_token=#{api_key}")
      .to_return(status: 200, body: plan.to_json, headers: json)

    expect(client.get_listing_membership_plan(listing_id: 1, membership_plan_id: 2)['credit_uses'])
      .to eq(%w[stays grooming])
  end
end
