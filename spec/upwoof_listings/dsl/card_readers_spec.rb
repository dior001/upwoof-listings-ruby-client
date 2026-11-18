# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::CardReaders do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:readers_url) { "#{base_url}/listings/1/card_readers" }

  it 'lists readers' do
    stub_request(:get, readers_url).with(query: { access_token: api_key, page: '2' })
                                   .to_return(status: 200, body: [{ id: 5, label: 'Front desk', online: true }].to_json,
                                              headers: json)

    readers = client.get_listing_card_readers(listing_id: 1, params: { page: 2 })
    expect(readers.first).to be_a(CardReader)
    expect(readers.first['online']).to be(true)
  end

  it 'registers a reader' do
    params = { label: 'Front desk', registration_code: 'simulated-wpe' }
    stub_request(:post, "#{readers_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 5, device_type: 'bbpos_wisepos_e' }.to_json, headers: json)

    expect(client.create_listing_card_reader(listing_id: 1, params: params)['device_type']).to eq('bbpos_wisepos_e')
  end

  it 'raises a ClientError without two-factor authentication' do
    stub_request(:post, "#{readers_url}?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.create_listing_card_reader(listing_id: 1, params: { label: 'x', registration_code: 'y' }) }
      .to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'raises a ValidationError when Stripe refuses the code' do
    stub_request(:post, "#{readers_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { error: 'card_reader_not_registered', message: 'Stripe refused the code' }.to_json,
                 headers: json)

    expect { client.create_listing_card_reader(listing_id: 1, params: { label: 'x', registration_code: 'y' }) }
      .to(raise_error(UpwoofListings::Errors::ValidationError) do |error|
        expect(error.errors).to eq(['Stripe refused the code'])
      end)
  end

  it 'removes a reader' do
    stub_request(:delete, "#{readers_url}/5?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_listing_card_reader(listing_id: 1, card_reader_id: 5)).to be(true)
  end

  payables = { 'invoices' => %i[invoice invoice_id], 'retail_sales' => %i[retail_sale retail_sale_id] }
  payables.each do |payables_path, (kind, key)|
    it "starts, reads and cancels a #{kind} terminal payment" do
      url = "#{base_url}/listings/1/#{payables_path}/9/terminal_payment"
      stub_request(:post, "#{url}?access_token=#{api_key}")
        .with(body: { card_reader_id: 5 }.to_json)
        .to_return(status: 201, body: { id: 3, status: 'processing' }.to_json, headers: json)
      stub_request(:get, "#{url}?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 3, status: 'succeeded' }.to_json, headers: json)
      stub_request(:post, "#{url}/cancel?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 3, status: 'canceled' }.to_json, headers: json)

      ids = { listing_id: 1, key => 9 }
      payment = client.public_send("create_#{kind}_terminal_payment", **ids, card_reader_id: 5)
      expect(payment).to be_a(TerminalPayment)
      expect(payment['status']).to eq('processing')
      expect(client.public_send("get_#{kind}_terminal_payment", **ids)['status']).to eq('succeeded')
      expect(client.public_send("cancel_#{kind}_terminal_payment", **ids)['status']).to eq('canceled')
    end
  end

  it 'raises a ResourceNotFoundError when no terminal payment was started' do
    stub_request(:get, "#{base_url}/listings/1/invoices/9/terminal_payment?access_token=#{api_key}")
      .to_return(status: 404, body: '{}')

    expect { client.get_invoice_terminal_payment(listing_id: 1, invoice_id: 9) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_card_readers(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_card_reader(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_card_reader(listing_id: 1, card_reader_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_invoice_terminal_payment(listing_id: 1, invoice_id: 9, card_reader_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_retail_sale_terminal_payment(listing_id: 1, retail_sale_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.cancel_invoice_terminal_payment(listing_id: '', invoice_id: 9) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
