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
        expect(UpwoofListings.client.get_invoice(id: id)).to be_a(Invoice)
      end
    end
  end

  # POST /invoices
  describe '#create_invoice' do
    it 'creates an invoice' do
      params = { order_id: 1, customer_id: 1 }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/invoices/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, invoice_number: 'INV-1' }.to_json, headers: { 'Content-Type' => 'application/json' })

      invoice = UpwoofListings.client.create_invoice(params: params)
      expect(invoice).to be_a(Invoice)
    end
  end

  # PUT /invoices/{id}
  describe '#update_invoice' do
    it 'updates an invoice' do
      id = 1
      params = { due_date: '2026-05-01' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/invoices/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, due_date: '2026-05-01' }.to_json, headers: { 'Content-Type' => 'application/json' })

      invoice = UpwoofListings.client.update_invoice(id: id, params: params)
      expect(invoice).to be_a(Invoice)
    end
  end

  # PATCH /invoices/{id}
  describe '#patch_invoice' do
    it 'partially updates an invoice' do
      id = 1
      params = { due_date: '2026-05-02' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/invoices/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, due_date: '2026-05-02' }.to_json, headers: { 'Content-Type' => 'application/json' })

      invoice = UpwoofListings.client.patch_invoice(id: id, params: params)
      expect(invoice).to be_a(Invoice)
    end
  end

  # POST /invoices/{id}/pay_out_of_band
  describe '#pay_invoice_out_of_band' do
    it 'pays an invoice out of band' do
      id = 1
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/invoices/#{id}/pay_out_of_band?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 200, body: { id: id, status: 'paid' }.to_json, headers: { 'Content-Type' => 'application/json' })

      invoice = UpwoofListings.client.pay_invoice_out_of_band(id: id)
      expect(invoice).to be_a(Invoice)
      expect(invoice['status']).to eq('paid')
    end
  end
end
