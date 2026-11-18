# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::CustomFields do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:answers) { [{ custom_field_definition_id: 7, value: 'Chip 123' }] }

  describe '#get_listing_custom_field_definitions' do
    it 'lists the definitions' do
      stub_request(:get, "#{base_url}/listings/1/custom_field_definitions")
        .with(query: { access_token: api_key, record_type: 'pet' })
        .to_return(status: 200, body: [{ id: 7, label: 'Microchip' }].to_json, headers: json)

      definitions = client.get_listing_custom_field_definitions(listing_id: 1, params: { record_type: 'pet' })
      expect(definitions.first).to be_a(CustomFieldDefinition)
    end

    it 'lists the stay feedback definitions' do
      stub_request(:get, "#{base_url}/listings/1/custom_field_definitions")
        .with(query: { access_token: api_key, record_type: 'stay_feedback' })
        .to_return(status: 200, body: [{ id: 8, record_type: 'stay_feedback' }].to_json, headers: json)

      definitions = client.get_listing_custom_field_definitions(listing_id: 1, params: { record_type: 'stay_feedback' })
      expect(definitions.first['record_type']).to eq('stay_feedback')
    end

    it 'raises an ArgumentError when the listing id is blank' do
      expect { client.get_listing_custom_field_definitions(listing_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  {
    update_customer_custom_fields: ['customers', Customer],
    update_pet_custom_fields: ['pets', Pet],
    update_reservation_custom_fields: ['reservations', Reservation]
  }.each do |method, (collection, resource)|
    describe "##{method}" do
      it 'puts the answers and returns the record' do
        stub_request(:put, "#{base_url}/#{collection}/5/custom_fields?access_token=#{api_key}")
          .with(body: { listing_id: 1, custom_fields: answers }.to_json)
          .to_return(status: 200, body: { id: 5, custom_fields: [{ display_value: 'Chip 123' }] }.to_json,
                     headers: json)

        record = client.public_send(method, id: 5, listing_id: 1, custom_fields: answers)
        expect(record).to be_a(resource)
        expect(record['custom_fields'].first['display_value']).to eq('Chip 123')
      end
    end
  end

  it 'exposes unknown field ids from a refusal' do
    stub_request(:put, "#{base_url}/pets/5/custom_fields?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'unprocessable entity', unknown_custom_field_ids: ['99'],
                                      errors: {} }.to_json)

    expect { client.update_pet_custom_fields(id: 5, listing_id: 1, custom_fields: answers) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |e|
        expect(e.body['unknown_custom_field_ids']).to eq(['99'])
        expect(e.errors).to eq([])
      }
  end

  it 'raises an ArgumentError for blank arguments' do
    expect { client.update_pet_custom_fields(id: '', listing_id: 1, custom_fields: answers) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.update_pet_custom_fields(id: 5, listing_id: '', custom_fields: answers) }
      .to raise_error(ArgumentError, 'Listing ID cannot be blank')
    expect { client.update_pet_custom_fields(id: 5, listing_id: 1, custom_fields: []) }
      .to raise_error(ArgumentError, 'Custom fields cannot be blank')
  end
end

describe UpwoofListings::DSL::SpecialOpeningHours do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  it 'lists the special hours from a date' do
    stub_request(:get, "#{base_url}/listings/1/special_opening_hours")
      .with(query: { access_token: api_key, from: '2026-12-01' })
      .to_return(status: 200, body: [{ id: 3, when_open: '09:00', pick_up_and_drop_off_windows: [] }].to_json)

    hours = client.get_listing_special_opening_hours(listing_id: 1, params: { from: '2026-12-01' })
    expect(hours.first).to be_a(SpecialOpeningHour)
    expect(hours.first['when_open']).to eq('09:00')
  end

  it 'raises an ArgumentError when the listing id is blank' do
    expect { client.get_listing_special_opening_hours(listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end

describe UpwoofListings::DSL::NotificationTemplates do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:templates_url) { "#{base_url}/listings/1/notification_templates" }

  it 'lists the wording' do
    stub_request(:get, "#{templates_url}?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 1, channel: 'email' }].to_json)

    expect(client.get_listing_notification_templates(listing_id: 1).first).to be_a(NotificationTemplateOverride)
  end

  it 'creates or updates wording' do
    params = { notification_key: 'upcoming_stay_reminder', channel: 'sms', enabled: false }
    stub_request(:put, "#{templates_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 200, body: { id: 2, enabled: false }.to_json)

    expect(client.update_listing_notification_template(listing_id: 1, params: params)['enabled']).to be(false)
  end

  it 'deletes wording with the key in the query string and no body' do
    stub = stub_request(:delete, templates_url)
           .with(query: { access_token: api_key, notification_key: 'invoice_finalized', channel: 'email',
                          reservation_type: 'grooming' })
           .with { |request| request.body.blank? }
           .to_return(status: 204)

    expect(client.delete_listing_notification_template(listing_id: 1, notification_key: 'invoice_finalized',
                                                       channel: 'email', reservation_type: 'grooming')).to be(true)
    expect(stub).to have_been_requested
  end

  it 'deletes without a reservation type, raising ResourceNotFoundError when there is no row' do
    stub_request(:delete, templates_url)
      .with(query: { access_token: api_key, notification_key: 'reservation_confirmed', channel: 'sms' })
      .to_return(status: 404, body: '{}')

    expect do
      client.delete_listing_notification_template(listing_id: 1, notification_key: 'reservation_confirmed',
                                                  channel: 'sms')
    end.to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'raises an ArgumentError for blank arguments' do
    expect { client.get_listing_notification_templates(listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.update_listing_notification_template(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_notification_template(listing_id: '', notification_key: 'k', channel: 'email') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_notification_template(listing_id: 1, notification_key: '', channel: 'email') }
      .to raise_error(ArgumentError, 'Notification key and channel cannot be blank')
  end
end
