require 'spec_helper'

describe UpwoofListings::DSL::Customers do
  # GET /customers
  describe '#get_customers' do
    it 'returns an array of customers' do
      VCR.use_cassette('get_customers') do
        customers = UpwoofListings.client.get_customers
        expect(customers).to be_a(Array)
        expect(customers.first).to be_a(Customer)
      end
    end
  end

  # GET /customers/{id}
  describe '#get_customer' do
    it 'returns a customer' do
      id = VCR.use_cassette('get_customers') do
        customers = UpwoofListings.client.get_customers
        customers.first['id']
      end

      VCR.use_cassette('get_customer') do
        expect(UpwoofListings.client.get_customer(id: id)).to be_a(Customer)
      end
    end
  end

  # POST /customers
  describe '#create_customer' do
    it 'creates a customer' do
      params = { first_name: 'John', last_name: 'Doe', email: 'john@example.com' }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/customers/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, first_name: 'John' }.to_json, headers: { 'Content-Type' => 'application/json' })

      customer = UpwoofListings.client.create_customer(params: params)
      expect(customer).to be_a(Customer)
    end
  end

  # PUT /customers/{id}
  describe '#update_customer' do
    it 'updates a customer' do
      id = 1
      params = { first_name: 'John Updated' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/customers/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, first_name: 'John Updated' }.to_json, headers: { 'Content-Type' => 'application/json' })

      customer = UpwoofListings.client.update_customer(id: id, params: params)
      expect(customer).to be_a(Customer)
    end
  end

  # PATCH /customers/{id}
  describe '#patch_customer' do
    it 'partially updates a customer' do
      id = 1
      params = { last_name: 'Doe Patched' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/customers/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, last_name: 'Doe Patched' }.to_json, headers: { 'Content-Type' => 'application/json' })

      customer = UpwoofListings.client.patch_customer(id: id, params: params)
      expect(customer).to be_a(Customer)
    end
  end

  # DELETE /customers/{id}
  describe '#delete_customer' do
    it 'deletes a customer' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/customers/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_customer(id: id)).to be true
    end
  end
end
