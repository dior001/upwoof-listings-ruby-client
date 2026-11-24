# frozen_string_literal: true

require 'spec_helper'

describe 'Batch 31 API changes' do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  describe UpwoofListings::DSL::Reservations do
    let(:url) { "#{base_url}/reservations/5/unit_assignments/9?access_token=#{api_key}" }

    it 'moves an assignment to a unit' do
      stub_request(:patch, url)
        .with(body: { accommodation_unit_id: 31 }.to_json)
        .to_return(status: 200, headers: json,
                   body: { id: 9, accommodation_id: 2,
                           accommodation_unit: { id: 31, name: 'A3', active: true, sort: 3,
                                                 needs_cleaning: false } }.to_json)

      assignment = client.update_reservation_unit_assignment(reservation_id: 5, unit_assignment_id: 9,
                                                             accommodation_unit_id: 31)
      expect(assignment).to be_a(ReservationAccommodationAssignment)
      expect(assignment['accommodation_unit']['name']).to eq('A3')
    end

    it 'takes an assignment out of its unit' do
      stub_request(:patch, url)
        .with(body: { accommodation_unit_id: nil }.to_json)
        .to_return(status: 200, headers: json, body: { id: 9, accommodation_id: 2, accommodation_unit: nil }.to_json)

      expect(client.update_reservation_unit_assignment(reservation_id: 5, unit_assignment_id: 9)['accommodation_unit'])
        .to be_nil
    end

    it 'raises a ValidationError when the unit is taken' do
      message = 'The unit is taken by another stay on some of these nights'
      stub_request(:patch, url).to_return(status: 422, headers: json, body: { errors: [message] }.to_json)

      expect { client.update_reservation_unit_assignment(reservation_id: 5, unit_assignment_id: 9) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
    end

    it 'refuses blank ids' do
      expect { client.update_reservation_unit_assignment(reservation_id: 5, unit_assignment_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe UpwoofListings::DSL::RecurringReservationSchedules do
    let(:url) { "#{base_url}/recurring_reservation_schedules/4" }
    let(:schedule) { { id: 4, listing_id: 1, active: true, skipped_dates: [], weekdays: %w[monday] } }

    it 'stops a schedule' do
      stub_request(:post, "#{url}/deactivate?access_token=#{api_key}")
        .to_return(status: 201, headers: json, body: schedule.merge(active: false).to_json)

      expect(client.deactivate_recurring_reservation_schedule(id: 4)['active']).to be(false)
    end

    it 'raises a ValidationError for a stopped schedule' do
      stub_request(:post, "#{url}/deactivate?access_token=#{api_key}")
        .to_return(status: 422, headers: json,
                   body: { error: 'unprocessable entity', message: 'This recurring booking has been stopped' }.to_json)

      expect { client.deactivate_recurring_reservation_schedule(id: 4) }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it 'skips a date' do
      stub_request(:post, "#{url}/skipped_dates?access_token=#{api_key}")
        .with(body: { date: '2026-12-07' }.to_json)
        .to_return(status: 201, headers: json, body: schedule.merge(skipped_dates: ['2026-12-07']).to_json)

      expect(client.skip_recurring_reservation_schedule_date(id: 4, date: Date.new(2026, 12, 7))['skipped_dates'])
        .to eq(['2026-12-07'])
    end

    it 'restores a date' do
      stub_request(:delete, "#{url}/skipped_dates/2026-12-07?access_token=#{api_key}")
        .to_return(status: 200, headers: json, body: schedule.to_json)

      expect(client.restore_recurring_reservation_schedule_date(id: 4, date: '2026-12-07')['skipped_dates']).to eq([])
    end

    it 'raises a ValidationError for a date that is not skipped' do
      stub_request(:delete, "#{url}/skipped_dates/2026-12-08?access_token=#{api_key}")
        .to_return(status: 422, headers: json,
                   body: { error: 'unprocessable entity', message: 'That date is not skipped' }.to_json)

      expect { client.restore_recurring_reservation_schedule_date(id: 4, date: '2026-12-08') }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it 'refuses blank arguments' do
      expect { client.deactivate_recurring_reservation_schedule(id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.skip_recurring_reservation_schedule_date(id: '', date: '2026-12-07') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.skip_recurring_reservation_schedule_date(id: 4, date: '') }
        .to raise_error(ArgumentError, 'Date cannot be blank')
      expect { client.restore_recurring_reservation_schedule_date(id: '', date: '2026-12-07') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.restore_recurring_reservation_schedule_date(id: 4, date: nil) }
        .to raise_error(ArgumentError, 'Date cannot be blank')
    end
  end

  describe UpwoofListings::DSL::AppointmentNoShows do
    { mark_grooming_appointment_no_show: 'grooming', mark_lesson_no_show: 'lessons',
      mark_tour_no_show: 'tours', mark_transport_no_show: 'transports' }.each do |method, kind_path|
      it "#{method} marks an appointment a no-show" do
        stub_request(:post, "#{base_url}/listings/1/#{kind_path}/appointments/12/no_show?access_token=#{api_key}")
          .to_return(status: 201, headers: json,
                     body: { id: 12, status: 'no_show', deposit_status: 'forfeited',
                             reminder_sent_at: '2026-11-23T20:00:00Z' }.to_json)

        appointment = client.public_send(method, listing_id: 1, appointment_id: 12)
        expect(appointment).to be_a(GroomingAppointment)
        expect(appointment['status']).to eq('no_show')
        expect(appointment['reminder_sent_at']).to eq('2026-11-23T20:00:00Z')
      end
    end

    it 'raises a ValidationError for an appointment that cannot be marked' do
      message = 'Only a scheduled or confirmed appointment whose start has passed can be marked a no-show'
      stub_request(:post, "#{base_url}/listings/1/grooming/appointments/12/no_show?access_token=#{api_key}")
        .to_return(status: 422, headers: json, body: { errors: [message] }.to_json)

      expect { client.mark_grooming_appointment_no_show(listing_id: 1, appointment_id: 12) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
    end

    it 'raises a ClientError when a held deposit needs an owner or manager' do
      stub_request(:post, "#{base_url}/listings/1/tours/appointments/12/no_show?access_token=#{api_key}")
        .to_return(status: 403, body: '{}')

      expect { client.mark_tour_no_show(listing_id: 1, appointment_id: 12) }
        .to raise_error(UpwoofListings::Errors::ClientError)
    end

    it 'refuses blank ids' do
      expect { client.mark_lesson_no_show(listing_id: 1, appointment_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.mark_lesson_no_show(listing_id: '', appointment_id: 12) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe UpwoofListings::DSL::PetCarePlans do
    let(:feeding_plan) do
      { id: 6, listing_id: 1, pet_id: 3, meal_label: 'Breakfast', time_of_day: '07:30', quantity: '1 cup',
        food_description: 'Kibble', special_feeding: false, created_by_user_id: 2 }
    end
    let(:medication_plan) do
      { id: 8, listing_id: 1, pet_id: 3, medication_name: 'Apoquel', dosage: '16 mg', frequency: 'twice_daily',
        dose_times: [], effective_dose_times: %w[08:00 18:00], instructions: 'With food' }
    end

    it 'lists and gets feeding plans' do
      stub_request(:get, "#{base_url}/pets/3/feeding_plans?access_token=#{api_key}&listing_id=1&page=2")
        .to_return(status: 200, headers: json, body: [feeding_plan].to_json)
      stub_request(:get, "#{base_url}/pets/3/feeding_plans/6?access_token=#{api_key}&listing_id=1")
        .to_return(status: 200, headers: json, body: feeding_plan.to_json)

      plans = client.get_pet_feeding_plans(pet_id: 3, listing_id: 1, params: { page: 2 })
      expect(plans.first).to be_a(PetFeedingPlan)
      expect(client.get_pet_feeding_plan(pet_id: 3, plan_id: 6, listing_id: 1)['meal_label']).to eq('Breakfast')
    end

    it 'creates, changes and removes a feeding plan' do
      params = { listing_id: 1, meal_label: 'Dinner', time_of_day: '18:00', special_feeding: true }
      stub_request(:post, "#{base_url}/pets/3/feeding_plans?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, headers: json, body: feeding_plan.merge(meal_label: 'Dinner').to_json)
      stub_request(:patch, "#{base_url}/pets/3/feeding_plans/6?access_token=#{api_key}")
        .with(body: { listing_id: 1, time_of_day: '' }.to_json)
        .to_return(status: 200, headers: json, body: feeding_plan.merge(time_of_day: nil).to_json)
      stub_request(:delete, "#{base_url}/pets/3/feeding_plans/6?access_token=#{api_key}&listing_id=1")
        .to_return(status: 204)

      expect(client.create_pet_feeding_plan(pet_id: 3, params: params)['meal_label']).to eq('Dinner')
      changed = client.patch_pet_feeding_plan(pet_id: 3, plan_id: 6, params: { listing_id: 1, time_of_day: '' })
      expect(changed['time_of_day']).to be_nil
      expect(client.delete_pet_feeding_plan(pet_id: 3, plan_id: 6, listing_id: 1)).to be(true)
    end

    it 'lists, gets, creates, changes and removes medication plans' do
      params = { listing_id: 1, medication_name: 'Apoquel', frequency: 'twice_daily', dose_times: %w[07:00 19:00] }
      stub_request(:get, "#{base_url}/pets/3/medication_plans?access_token=#{api_key}&listing_id=1")
        .to_return(status: 200, headers: json, body: [medication_plan].to_json)
      stub_request(:get, "#{base_url}/pets/3/medication_plans/8?access_token=#{api_key}&listing_id=1")
        .to_return(status: 200, headers: json, body: medication_plan.to_json)
      stub_request(:post, "#{base_url}/pets/3/medication_plans?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, headers: json, body: medication_plan.merge(dose_times: %w[07:00 19:00]).to_json)
      stub_request(:patch, "#{base_url}/pets/3/medication_plans/8?access_token=#{api_key}")
        .with(body: { listing_id: 1, frequency: 'as_needed' }.to_json)
        .to_return(status: 200, headers: json,
                   body: medication_plan.merge(frequency: 'as_needed', effective_dose_times: []).to_json)
      stub_request(:delete, "#{base_url}/pets/3/medication_plans/8?access_token=#{api_key}&listing_id=1")
        .to_return(status: 204)

      expect(client.get_pet_medication_plans(pet_id: 3, listing_id: 1).first).to be_a(PetMedicationPlan)
      expect(client.get_pet_medication_plan(pet_id: 3, plan_id: 8, listing_id: 1)['effective_dose_times'])
        .to eq(%w[08:00 18:00])
      expect(client.create_pet_medication_plan(pet_id: 3, params: params)['dose_times']).to eq(%w[07:00 19:00])
      changed = client.patch_pet_medication_plan(pet_id: 3, plan_id: 8,
                                                 params: { listing_id: 1, frequency: 'as_needed' })
      expect(changed['effective_dose_times']).to eq([])
      expect(client.delete_pet_medication_plan(pet_id: 3, plan_id: 8, listing_id: 1)).to be(true)
    end

    it 'raises a ValidationError for a refused plan' do
      stub_request(:post, "#{base_url}/pets/3/medication_plans?access_token=#{api_key}")
        .to_return(status: 422, headers: json,
                   body: { error: 'unprocessable entity', message: "Dose times couldn't be read" }.to_json)

      expect { client.create_pet_medication_plan(pet_id: 3, params: { listing_id: 1, medication_name: 'X' }) }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it 'raises a ResourceNotFoundError for a plan elsewhere' do
      stub_request(:delete, "#{base_url}/pets/3/medication_plans/8?access_token=#{api_key}&listing_id=1")
        .to_return(status: 404, body: '{}')

      expect { client.delete_pet_medication_plan(pet_id: 3, plan_id: 8, listing_id: 1) }
        .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
    end

    it 'refuses blank ids' do
      expect { client.get_pet_feeding_plans(pet_id: 3, listing_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.get_pet_medication_plan(pet_id: 3, plan_id: '', listing_id: 1) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.create_pet_feeding_plan(pet_id: '', params: {}) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe UpwoofListings::DSL::CareLogEntries do
    let(:entry) do
      { id: 21, reservation_id: 5, pet_id: 3, entry_type: 'medication', outcome: nil,
        scheduled_at: '2026-11-24T19:00:00Z', completed_at: nil }
    end

    it 'lists a stay\'s care log' do
      stub_request(:get, "#{base_url}/reservations/5/care_log_entries?access_token=#{api_key}&date=2026-11-24" \
                         '&status=pending')
        .to_return(status: 200, headers: json, body: [entry].to_json)

      entries = client.get_reservation_care_log_entries(reservation_id: 5,
                                                        params: { date: '2026-11-24', status: 'pending' })
      expect(entries.first).to be_a(CareLogEntry)
      expect(entries.first['entry_type']).to eq('medication')
    end

    it 'completes a task' do
      params = { outcome: 'refused', administration_notes: 'Spat it out' }
      stub_request(:post, "#{base_url}/care_log_entries/21/complete?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, headers: json, body: entry.merge(outcome: 'refused').to_json)

      expect(client.complete_care_log_entry(id: 21, params: params)['outcome']).to eq('refused')
    end

    it 'raises a ValidationError for a task already done' do
      stub_request(:post, "#{base_url}/care_log_entries/21/complete?access_token=#{api_key}")
        .to_return(status: 422, headers: json,
                   body: { error: 'unprocessable entity', message: 'This task is already done' }.to_json)

      expect { client.complete_care_log_entry(id: 21) }.to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it 'refuses blank ids' do
      expect { client.get_reservation_care_log_entries(reservation_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.complete_care_log_entry(id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe UpwoofListings::DSL::Orders do
    it 'holds a gift card as a payment' do
      stub_request(:post, "#{base_url}/orders/7/redeem_gift_card?access_token=#{api_key}")
        .with(body: { code: 'GC-1' }.to_json)
        .to_return(status: 200, headers: json,
                   body: { id: 7, price_cents: 10_000, order_line_items: [],
                           gift_card_holds: [{ id: 1, gift_card_id: 4, amount_cents: 2500, currency: 'NZD',
                                               invoice_payment_id: nil, settled_at: nil,
                                               reversed_at: nil }] }.to_json)

      order = client.redeem_gift_card(id: 7, code: 'GC-1')
      expect(order['price_cents']).to eq(10_000)
      expect(order['gift_card_holds'].first['amount_cents']).to eq(2500)
    end
  end
end
