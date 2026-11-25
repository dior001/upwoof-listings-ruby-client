# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::EmailAddresses do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:addresses_url) { "#{base_url}/listings/1/email_addresses" }

  it 'lists email addresses' do
    stub_request(:get, "#{addresses_url}?access_token=#{api_key}&page=2")
      .to_return(status: 200, headers: json,
                 body: [{ id: 2, role_key: 'bookings', email_address: 'bookings+1@upwoof.net' }].to_json)

    addresses = client.get_listing_email_addresses(listing_id: 1, params: { page: 2 })
    expect(addresses.first).to be_a(ListingEmailAddress)
    expect(addresses.first['email_address']).to eq('bookings+1@upwoof.net')
  end

  it 'gets an email address' do
    stub_request(:get, "#{addresses_url}/2?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 2, recipient_scope: 'owners_and_managers' }.to_json, headers: json)

    address = client.get_listing_email_address(listing_id: 1, listing_email_address_id: 2)
    expect(address['recipient_scope']).to eq('owners_and_managers')
  end

  it 'raises a ResourceNotFoundError for an address that is not the listing\'s' do
    stub_request(:get, "#{addresses_url}/9?access_token=#{api_key}")
      .to_return(status: 404, body: { error: 'not_found' }.to_json, headers: json)

    expect { client.get_listing_email_address(listing_id: 1, listing_email_address_id: 9) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'creates an email address' do
    params = { name: 'Grooming', role_key: 'grooming', recipient_scope: 'selected', selected_user_ids: [5] }
    stub_request(:post, "#{addresses_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 3, role_key: 'grooming', selected_user_ids: [5] }.to_json, headers: json)

    expect(client.create_listing_email_address(listing_id: 1, params: params)['selected_user_ids']).to eq([5])
  end

  it 'raises a ValidationError for a reserved role key' do
    stub_request(:post, "#{addresses_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['Role key is reserved'] }.to_json, headers: json)

    expect { client.create_listing_email_address(listing_id: 1, params: { name: 'Admin', role_key: 'admin' }) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'patches an email address' do
    stub_request(:patch, "#{addresses_url}/3?access_token=#{api_key}")
      .with(body: { active: false }.to_json)
      .to_return(status: 200, body: { id: 3, active: false }.to_json, headers: json)

    address = client.patch_listing_email_address(listing_id: 1, listing_email_address_id: 3,
                                                 params: { active: false })
    expect(address['active']).to be(false)
  end

  it "raises a ValidationError when changing the bookings address's role key" do
    stub_request(:patch, "#{addresses_url}/2?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'bookings_role_key', message: "Can't change" }.to_json, headers: json)

    expect do
      client.patch_listing_email_address(listing_id: 1, listing_email_address_id: 2, params: { role_key: 'stays' })
    end.to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'deletes an email address' do
    stub_request(:delete, "#{addresses_url}/3?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_listing_email_address(listing_id: 1, listing_email_address_id: 3)).to be(true)
  end

  it 'raises a ValidationError when deleting the bookings address' do
    stub_request(:delete, "#{addresses_url}/2?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'bookings_address', message: "Can't delete" }.to_json, headers: json)

    expect { client.delete_listing_email_address(listing_id: 1, listing_email_address_id: 2) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'lists inbound emails' do
    stub_request(:get, "#{base_url}/listings/1/inbound_emails")
      .with(query: { access_token: api_key, outcome: 'lead_created', since: '2026-11-01T00:00:00Z' })
      .to_return(status: 200, headers: json,
                 body: [{ id: 7, outcome: 'lead_created', lead_id: 4, reason: nil, sender_verified: true }].to_json)

    emails = client.get_listing_inbound_emails(listing_id: 1,
                                               params: { outcome: 'lead_created', since: '2026-11-01T00:00:00Z' })
    expect(emails.first).to be_a(InboundEmailRecord)
    expect(emails.first['lead_id']).to eq(4)
  end

  it "reads a customer's UpWoof email address" do
    stub_request(:get, "#{base_url}/customers/5?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 5, upwoof_email_address: 'jo+abc123@upwoof.net' }.to_json, headers: json)

    expect(client.get_customer(id: 5)['upwoof_email_address']).to eq('jo+abc123@upwoof.net')
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_email_addresses(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_email_address(listing_id: 1, listing_email_address_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_email_address(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_listing_email_address(listing_id: 1, listing_email_address_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_email_address(listing_id: '', listing_email_address_id: 2) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_inbound_emails(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
