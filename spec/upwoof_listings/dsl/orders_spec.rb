require 'spec_helper'

describe UpwoofListings::DSL::Orders do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_orders' do
    it 'returns an array of orders' do
      stub_request(:get, "#{base_url}/orders/?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, order_number: 'ORD-1' }].to_json, headers: { 'Content-Type' => 'application/json' })

      orders = client.get_orders
      expect(orders).to be_a(Array)
      expect(orders.first).to be_a(Order)
      expect(orders.first['order_number']).to eq('ORD-1')
    end
  end

  describe '#get_order' do
    it 'returns an order' do
      stub_request(:get, "#{base_url}/orders/1?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 1, order_number: 'ORD-1' }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.get_order(id: 1)
      expect(order).to be_a(Order)
      expect(order['order_number']).to eq('ORD-1')
    end
  end

  describe '#create_order' do
    it 'creates an order' do
      params = { customer_id: 1, items: [{ name: 'Dog Food', price: 10.0 }] }
      stub_request(:post, "#{base_url}/orders/?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, order_number: 'ORD-2' }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.create_order(params: params)
      expect(order).to be_a(Order)
    end
  end

  describe '#update_order' do
    it 'updates an order' do
      params = { status: 'shipped' }
      stub_request(:put, "#{base_url}/orders/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, status: 'shipped' }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.update_order(id: 2, params: params)
      expect(order).to be_a(Order)
    end
  end

  describe '#patch_order' do
    it 'partially updates an order' do
      params = { status: 'delivered' }
      stub_request(:patch, "#{base_url}/orders/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, status: 'delivered' }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.patch_order(id: 2, params: params)
      expect(order).to be_a(Order)
    end
  end

  describe '#apply_promo_code' do
    it 'applies the promo code and returns the updated order' do
      stub_request(:post, "#{base_url}/orders/2/apply_promo_code?access_token=#{api_key}")
        .with(body: { code: 'SAVE10' }.to_json)
        .to_return(status: 200, body: { id: 2, price_cents: 900 }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.apply_promo_code(id: 2, code: 'SAVE10')
      expect(order).to be_a(Order)
      expect(order['price_cents']).to eq(900)
    end

    it 'raises for a blank id' do
      expect { client.apply_promo_code(id: nil, code: 'SAVE10') }.to raise_error(ArgumentError)
    end

    it 'raises for a blank code' do
      expect { client.apply_promo_code(id: 2, code: nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#redeem_gift_card' do
    it 'redeems the gift card and returns the updated order' do
      stub_request(:post, "#{base_url}/orders/2/redeem_gift_card?access_token=#{api_key}")
        .with(body: { code: 'GIFT123' }.to_json)
        .to_return(status: 200, body: { id: 2, price_cents: 500 }.to_json, headers: { 'Content-Type' => 'application/json' })

      order = client.redeem_gift_card(id: 2, code: 'GIFT123')
      expect(order).to be_a(Order)
      expect(order['price_cents']).to eq(500)
    end

    it 'raises for a blank id' do
      expect { client.redeem_gift_card(id: nil, code: 'GIFT123') }.to raise_error(ArgumentError)
    end

    it 'raises for a blank code' do
      expect { client.redeem_gift_card(id: 2, code: nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete_order' do
    it 'deletes an order' do
      stub_request(:delete, "#{base_url}/orders/2?access_token=#{api_key}")
        .to_return(status: 204)

      expect(client.delete_order(id: 2)).to be true
    end
  end
end
