# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::PricingRules do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:rules_url) { "#{base_url}/listings/1/pricing_rules" }

  it 'lists rules' do
    stub_request(:get, "#{rules_url}?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 3, breed_ids: [1, 2] }].to_json, headers: json)

    rules = client.get_listing_pricing_rules(listing_id: 1)
    expect(rules.first).to be_a(PricingRule)
    expect(rules.first['breed_ids']).to eq([1, 2])
  end

  it 'gets a rule' do
    stub_request(:get, "#{rules_url}/3?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 3 }.to_json, headers: json)

    expect(client.get_listing_pricing_rule(listing_id: 1, pricing_rule_id: 3)['id']).to eq(3)
  end

  it 'creates a rule' do
    params = { name: 'Big dogs', animal_type_id: 1, direction: 'surcharge', adjustment_percent: 10 }
    stub_request(:post, "#{rules_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 4, name: 'Big dogs' }.to_json, headers: json)

    expect(client.create_listing_pricing_rule(listing_id: 1, params: params)['name']).to eq('Big dogs')
  end

  it 'patches a rule, clearing a field' do
    stub_request(:patch, "#{rules_url}/3?access_token=#{api_key}")
      .with(body: { customer_id: nil }.to_json)
      .to_return(status: 200, body: { id: 3, customer_id: nil }.to_json, headers: json)

    expect(client.patch_listing_pricing_rule(listing_id: 1, pricing_rule_id: 3, params: { customer_id: nil })['id'])
      .to eq(3)
  end

  it 'deletes a rule' do
    stub_request(:delete, "#{rules_url}/3?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_listing_pricing_rule(listing_id: 1, pricing_rule_id: 3)).to be(true)
  end

  it 'raises a ClientError for a staff member' do
    stub_request(:get, "#{rules_url}?access_token=#{api_key}").to_return(status: 403, body: '{}')

    expect { client.get_listing_pricing_rules(listing_id: 1) }.to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_pricing_rules(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_pricing_rule(listing_id: 1, pricing_rule_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_pricing_rule(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_listing_pricing_rule(listing_id: '', pricing_rule_id: 3, params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_pricing_rule(listing_id: 1, pricing_rule_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end

describe UpwoofListings::DSL::MembershipPlans do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  it 'lists plans, clamping per_page' do
    stub_request(:get, "#{base_url}/listings/1/membership_plans")
      .with(query: { access_token: api_key, per_page: '100' })
      .to_return(status: 200, body: [{ id: 2, stay_discount_percent: 10.0 }].to_json, headers: json)

    plans = client.get_listing_membership_plans(listing_id: 1, params: { per_page: 500 })
    expect(plans.first).to be_a(MembershipPlan)
    expect(plans.first['stay_discount_percent']).to eq(10.0)
  end

  it 'gets a plan' do
    stub_request(:get, "#{base_url}/listings/1/membership_plans/2?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 2 }.to_json, headers: json)

    expect(client.get_listing_membership_plan(listing_id: 1, membership_plan_id: 2)['id']).to eq(2)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_membership_plans(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_membership_plan(listing_id: 1, membership_plan_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
