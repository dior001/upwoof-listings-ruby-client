# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::StayProducts do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:items_url) { "#{base_url}/reservations/3/retail_items" }

  it 'lists the products a stay can take' do
    stub_request(:get, "#{base_url}/listings/1/stay_products?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 4, name: 'Chew toy', quantity_on_hand: 9 }].to_json, headers: json)

    products = client.get_listing_stay_products(listing_id: 1)
    expect(products.first).to be_a(StayProduct)
    expect(products.first['quantity_on_hand']).to eq(9)
  end

  it 'lists and adds a stay\'s products' do
    stub_request(:get, "#{items_url}?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 6, retail_product_id: 4, quantity: 2 }].to_json, headers: json)
    stub_request(:post, "#{items_url}?access_token=#{api_key}")
      .with(body: { retail_product_id: 4, quantity: 2 }.to_json)
      .to_return(status: 201, body: { id: 6, name: 'Chew toy', quantity: 2 }.to_json, headers: json)

    expect(client.get_reservation_retail_items(reservation_id: 3).first).to be_a(ReservationRetailItem)
    item = client.create_reservation_retail_item(reservation_id: 3, params: { retail_product_id: 4, quantity: 2 })
    expect(item['name']).to eq('Chew toy')
  end

  it 'raises a ValidationError when the product is already on the stay' do
    stub_request(:post, "#{items_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['This product is already on the stay'] }.to_json, headers: json)

    expect { client.create_reservation_retail_item(reservation_id: 3, params: { retail_product_id: 4 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error|
        expect(error.errors).to eq(['This product is already on the stay'])
      }
  end

  it 'changes how many of a product a stay carries' do
    stub_request(:patch, "#{items_url}/6?access_token=#{api_key}")
      .with(body: { quantity: 3 }.to_json)
      .to_return(status: 200, body: { id: 6, quantity: 3, unit_price_cents: 1200 }.to_json, headers: json)

    item = client.patch_reservation_retail_item(reservation_id: 3, retail_item_id: 6, params: { quantity: 3 })
    expect(item).to be_a(ReservationRetailItem)
    expect(item['quantity']).to eq(3)
  end

  it 'raises a ValidationError when there is not enough in stock' do
    stub_request(:patch, "#{items_url}/6?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['Not enough in stock'] }.to_json, headers: json)

    expect { client.patch_reservation_retail_item(reservation_id: 3, retail_item_id: 6, params: { quantity: 50 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq(['Not enough in stock']) }
  end

  it 'removes a product from a stay' do
    stub_request(:delete, "#{items_url}/6?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_reservation_retail_item(reservation_id: 3, retail_item_id: 6)).to be(true)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_stay_products(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_reservation_retail_items(reservation_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_reservation_retail_item(reservation_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_reservation_retail_item(reservation_id: 3, retail_item_id: '', params: { quantity: 1 }) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_reservation_retail_item(reservation_id: 3, retail_item_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
