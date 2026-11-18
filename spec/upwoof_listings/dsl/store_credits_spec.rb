# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::StoreCredits do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  describe '#get_customer_store_credit' do
    it 'returns the balance at the listing' do
      stub_request(:get, "#{base_url}/customers/2/store_credit")
        .with(query: { access_token: api_key, listing_id: '1' })
        .to_return(status: 200, body: { id: nil, balance_cents: 0, currency: 'NZD' }.to_json, headers: json)

      account = client.get_customer_store_credit(customer_id: 2, listing_id: 1)
      expect(account).to be_a(StoreCreditAccount)
      expect(account['balance_cents']).to eq(0)
    end

    it 'raises an ArgumentError for a blank customer or listing' do
      expect { client.get_customer_store_credit(customer_id: '', listing_id: 1) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.get_customer_store_credit(customer_id: 2, listing_id: '') }
        .to raise_error(ArgumentError, 'Listing ID cannot be blank')
    end
  end

  describe '#get_customer_store_credit_transactions' do
    it 'returns the ledger' do
      stub_request(:get, "#{base_url}/customers/2/store_credit/transactions")
        .with(query: { access_token: api_key, listing_id: '1', page: '2' })
        .to_return(status: 200, body: [{ id: 9, entry_type: 'redemption' }].to_json, headers: json)

      transactions = client.get_customer_store_credit_transactions(customer_id: 2, listing_id: 1, params: { page: 2 })
      expect(transactions.first).to be_a(StoreCreditTransaction)
    end

    it 'works without params' do
      stub_request(:get, "#{base_url}/customers/2/store_credit/transactions")
        .with(query: { access_token: api_key, listing_id: '1' })
        .to_return(status: 200, body: [].to_json, headers: json)

      expect(client.get_customer_store_credit_transactions(customer_id: 2, listing_id: 1)).to eq([])
    end

    it 'raises an ArgumentError for a blank customer or listing' do
      expect { client.get_customer_store_credit_transactions(customer_id: '', listing_id: 1) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.get_customer_store_credit_transactions(customer_id: 2, listing_id: '') }
        .to raise_error(ArgumentError, 'Listing ID cannot be blank')
    end
  end

  describe '#adjust_customer_store_credit' do
    let(:params) { { listing_id: 1, amount_cents: 1500, reason: 'Goodwill' } }

    it 'records the adjustment' do
      stub_request(:post, "#{base_url}/customers/2/store_credit/adjustments?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 10, entry_type: 'manual_adjustment' }.to_json, headers: json)

      expect(client.adjust_customer_store_credit(customer_id: 2, params: params)['entry_type'])
        .to eq('manual_adjustment')
    end

    it 'raises a ValidationError when the balance is too low' do
      stub_request(:post, "#{base_url}/customers/2/store_credit/adjustments?access_token=#{api_key}")
        .to_return(status: 422, body: { error: 'unprocessable entity', message: 'Insufficient store credit' }.to_json)

      expect { client.adjust_customer_store_credit(customer_id: 2, params: params) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |e| expect(e.errors).to eq(['Insufficient store credit']) }
    end

    it 'raises an ArgumentError when the customer id is blank' do
      expect { client.adjust_customer_store_credit(customer_id: '', params: params) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
