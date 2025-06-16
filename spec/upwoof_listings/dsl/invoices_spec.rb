require 'spec_helper'

describe UpwoofListings::DSL::Invoices do
  # GET /invoices
  describe '#get_invoices' do
    it 'returns an array of invoices' do
      VCR.use_cassette('get_invoices') do
        invoices = UpwoofListings.client.get_invoices
        expect(invoices).to be_a(Array)
        expect(invoices.first).to be_a(Invoice)
      end
    end
  end

  # GET /invoices/{id}
  describe '#get_invoice' do
    it 'returns an invoice' do
      id = VCR.use_cassette('get_invoices') do
        invoices = UpwoofListings.client.get_invoices
        invoices.first['id']
      end

      VCR.use_cassette('get_invoice') do
        expect(UpwoofListings.client.get_invoice(id:)).to be_a(Invoice)
      end
    end
  end
end
