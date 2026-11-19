# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::InvoicePayments do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:payments_url) { "#{base_url}/invoices/5/payments" }
  let(:part) do
    { id: 8, invoice_id: 5, listing_id: 1, tender: 'cash', amount_cents: 2000, currency: 'NZD', net_amount_cents: 2000,
      refundable_cents: 2000, refunded_cents: 0, reported_to_stripe: false, recorded_by_user_id: 3, reversed_at: nil,
      source_type: nil, source_id: nil }
  end

  it 'lists an invoice\'s parts' do
    stub_request(:get, "#{payments_url}?access_token=#{api_key}&page=2")
      .to_return(status: 200, body: [part].to_json, headers: json)

    parts = client.get_invoice_payments(invoice_id: 5, params: { page: 2 })
    expect(parts.first).to be_a(InvoicePayment)
    expect(parts.first['tender']).to eq('cash')
    expect(parts.first['refundable_cents']).to eq(2000)
  end

  it 'records a cash part' do
    stub_request(:post, "#{payments_url}?access_token=#{api_key}")
      .with(body: { tender: 'cash', amount_cents: 2000 }.to_json)
      .to_return(status: 201, body: part.to_json, headers: json)

    expect(client.create_invoice_payment(invoice_id: 5, params: { tender: 'cash', amount_cents: 2000 })['id']).to eq(8)
  end

  it 'raises a ValidationError for a bad amount' do
    stub_request(:post, "#{payments_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['Amount is more than the invoice still owes'] }.to_json, headers: json)

    expect { client.create_invoice_payment(invoice_id: 5, params: { tender: 'check', amount_cents: 99_999 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error|
        expect(error.errors).to eq(['Amount is more than the invoice still owes'])
      }
  end

  it 'raises a ClientError for a staff member' do
    stub_request(:post, "#{payments_url}?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.create_invoice_payment(invoice_id: 5, params: { tender: 'cash' }) }
      .to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'refunds part of a part' do
    refunded = part.merge(refunded_cents: 500, net_amount_cents: 1500, refundable_cents: 1500)
    stub_request(:post, "#{payments_url}/8/refund?access_token=#{api_key}")
      .with(body: { amount_cents: 500 }.to_json)
      .to_return(status: 200, body: refunded.to_json, headers: json)

    refunded_part = client.refund_invoice_payment(invoice_id: 5, payment_id: 8, params: { amount_cents: 500 })
    expect(refunded_part).to be_a(InvoicePayment)
    expect(refunded_part['net_amount_cents']).to eq(1500)
  end

  it 'refunds a whole part' do
    stub_request(:post, "#{payments_url}/8/refund?access_token=#{api_key}")
      .to_return(status: 200, body: part.merge(refunded_cents: 2000, refundable_cents: 0).to_json, headers: json)

    expect(client.refund_invoice_payment(invoice_id: 5, payment_id: 8)['refundable_cents']).to eq(0)
  end

  it 'raises a ResourceNotFoundError for another invoice\'s part' do
    stub_request(:post, "#{payments_url}/9/refund?access_token=#{api_key}").to_return(status: 404, body: '{}')

    expect { client.refund_invoice_payment(invoice_id: 5, payment_id: 9) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'names the part a credit note refunds through' do
    params = { invoice_id: 5, invoice_payment_id: 8, credit_note_line_items: [] }
    stub_request(:post, "#{base_url}/credit_notes/?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 12, invoice_id: 5 }.to_json, headers: json)

    expect(client.create_credit_note(params: params)['id']).to eq(12)
  end

  it 'raises a ValidationError for a credit note on a split-paid invoice without a part' do
    message = 'Payment to refund must be chosen: this invoice was paid in parts'
    stub_request(:post, "#{base_url}/credit_notes/?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: [message] }.to_json, headers: json)

    expect { client.create_credit_note(params: { invoice_id: 5 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq([message]) }
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_invoice_payments(invoice_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_invoice_payment(invoice_id: '', params: { tender: 'cash' }) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.refund_invoice_payment(invoice_id: 5, payment_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
