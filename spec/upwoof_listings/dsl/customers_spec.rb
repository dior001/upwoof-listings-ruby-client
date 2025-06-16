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
        expect(UpwoofListings.client.get_customer(id:)).to be_a(Customer)
      end
    end
  end
end
