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

  describe '#delete_order' do
    it 'deletes an order' do
      stub_request(:delete, "#{base_url}/orders/2?access_token=#{api_key}")
        .to_return(status: 204)

      expect(client.delete_order(id: 2)).to be true
    end
  end
end
