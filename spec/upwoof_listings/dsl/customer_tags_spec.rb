# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::CustomerTags do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:tags_url) { "#{base_url}/listings/1/customer_tags" }

  it 'lists tags' do
    stub_request(:get, "#{tags_url}?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 5, name: 'VIP', colour: 'warning' }].to_json, headers: json)

    tags = client.get_listing_customer_tags(listing_id: 1)
    expect(tags.first).to be_a(CustomerTag)
    expect(tags.first['colour']).to eq('warning')
  end

  it 'creates, patches and deletes a tag' do
    stub_request(:post, "#{tags_url}?access_token=#{api_key}")
      .with(body: { name: 'VIP', colour: 'warning' }.to_json)
      .to_return(status: 201, body: { id: 5, name: 'VIP' }.to_json, headers: json)
    stub_request(:patch, "#{tags_url}/5?access_token=#{api_key}")
      .with(body: { colour: 'danger' }.to_json)
      .to_return(status: 200, body: { id: 5, colour: 'danger' }.to_json, headers: json)
    stub_request(:delete, "#{tags_url}/5?access_token=#{api_key}").to_return(status: 204)

    expect(client.create_listing_customer_tag(listing_id: 1, params: { name: 'VIP', colour: 'warning' })['id']).to eq(5)
    expect(client.patch_listing_customer_tag(listing_id: 1, tag_id: 5, params: { colour: 'danger' })['colour'])
      .to eq('danger')
    expect(client.delete_listing_customer_tag(listing_id: 1, tag_id: 5)).to be(true)
  end

  it 'raises a ValidationError deleting a tag a pricing rule uses' do
    stub_request(:delete, "#{tags_url}/5?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'unprocessable entity', message: 'Pricing rules use this tag' }.to_json,
                 headers: json)

    expect { client.delete_listing_customer_tag(listing_id: 1, tag_id: 5) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'tags and untags a customer' do
    stub_request(:post, "#{tags_url}/5/customers?access_token=#{api_key}")
      .with(body: { customer_id: 7 }.to_json)
      .to_return(status: 201, body: { id: 8, customer_id: 7, customer_tag_id: 5 }.to_json, headers: json)
    stub_request(:delete, "#{tags_url}/5/customers")
      .with(query: { access_token: api_key, customer_id: '7' })
      .to_return(status: 204)

    tagging = client.tag_listing_customer(listing_id: 1, tag_id: 5, customer_id: 7)
    expect(tagging).to be_a(CustomerTagging)
    expect(tagging['customer_tag_id']).to eq(5)
    expect(client.untag_listing_customer(listing_id: 1, tag_id: 5, customer_id: 7)).to be(true)
  end

  it 'raises a ClientError for a staff member' do
    stub_request(:get, "#{tags_url}?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.get_listing_customer_tags(listing_id: 1) }.to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'filters customers by tag' do
    stub_request(:get, "#{base_url}/customers/")
      .with(query: { access_token: api_key, customer_tag_id: '5' })
      .to_return(status: 200, body: [{ id: 7, customer_tags: [{ id: 5, name: 'VIP' }] }].to_json, headers: json)

    customers = client.get_customers(params: { customer_tag_id: 5 })
    expect(customers.first['customer_tags'].first['name']).to eq('VIP')
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_customer_tags(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_customer_tag(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_listing_customer_tag(listing_id: 1, tag_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_customer_tag(listing_id: 1, tag_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.tag_listing_customer(listing_id: 1, tag_id: 5, customer_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.untag_listing_customer(listing_id: 1, tag_id: '', customer_id: 7) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
