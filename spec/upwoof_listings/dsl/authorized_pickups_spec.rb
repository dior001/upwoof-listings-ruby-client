# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::AuthorizedPickups do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:pickups_url) { "#{base_url}/customers/7/authorized_pickups" }

  it 'lists pickups, sending the listing' do
    stub_request(:get, pickups_url)
      .with(query: { access_token: api_key, listing_id: '1', page: '2' })
      .to_return(status: 200, body: [{ id: 3, name: 'Aunt Jo', relationship: 'Aunt' }].to_json, headers: json)

    pickups = client.get_customer_authorized_pickups(customer_id: 7, listing_id: 1, params: { page: 2 })
    expect(pickups.first).to be_a(AuthorizedPickup)
    expect(pickups.first['relationship']).to eq('Aunt')
  end

  it 'gets a pickup' do
    stub_request(:get, "#{pickups_url}/3")
      .with(query: { access_token: api_key, listing_id: '1' })
      .to_return(status: 200, body: { id: 3, name: 'Aunt Jo' }.to_json, headers: json)

    expect(client.get_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: 3, listing_id: 1)['name'])
      .to eq('Aunt Jo')
  end

  it 'creates and patches a pickup' do
    params = { listing_id: 1, name: 'Aunt Jo', phone: '+64211234567' }
    stub_request(:post, "#{pickups_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 3, name: 'Aunt Jo' }.to_json, headers: json)
    stub_request(:patch, "#{pickups_url}/3?access_token=#{api_key}")
      .with(body: { listing_id: 1, notes: 'Bring ID' }.to_json)
      .to_return(status: 200, body: { id: 3, notes: 'Bring ID' }.to_json, headers: json)

    expect(client.create_customer_authorized_pickup(customer_id: 7, params: params)['id']).to eq(3)
    patched = client.patch_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: 3,
                                                      params: { listing_id: 1, notes: 'Bring ID' })
    expect(patched['notes']).to eq('Bring ID')
  end

  it 'raises a ValidationError for a blank name' do
    stub_request(:post, "#{pickups_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'unprocessable entity', message: "Name can't be blank" }.to_json,
                 headers: json)

    expect { client.create_customer_authorized_pickup(customer_id: 7, params: { listing_id: 1, name: '' }) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'deletes a pickup' do
    stub_request(:delete, "#{pickups_url}/3")
      .with(query: { access_token: api_key, listing_id: '1' })
      .to_return(status: 204)

    expect(client.delete_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: 3, listing_id: 1)).to be(true)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_customer_authorized_pickups(customer_id: 7, listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: '', listing_id: 1) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_customer_authorized_pickup(customer_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_customer_authorized_pickup(customer_id: 7, authorized_pickup_id: 3, listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
