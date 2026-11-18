# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::PlayYards do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:yards_url) { "#{base_url}/listings/1/play_yards" }
  let(:assignments_url) { "#{base_url}/listings/1/playgroup_assignments" }

  it 'lists yards' do
    stub_request(:get, "#{yards_url}?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 2, name: 'Big yard', capacity: 12 }].to_json, headers: json)

    yards = client.get_listing_play_yards(listing_id: 1)
    expect(yards.first).to be_a(PlayYard)
    expect(yards.first['capacity']).to eq(12)
  end

  it 'gets a yard' do
    stub_request(:get, "#{yards_url}/2?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 2 }.to_json, headers: json)

    expect(client.get_listing_play_yard(listing_id: 1, play_yard_id: 2)['id']).to eq(2)
  end

  it 'creates a yard' do
    params = { name: 'Small yard', capacity: 6, max_weight_lbs: 25.0 }
    stub_request(:post, "#{yards_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 3, name: 'Small yard' }.to_json, headers: json)

    expect(client.create_listing_play_yard(listing_id: 1, params: params)['name']).to eq('Small yard')
  end

  it 'raises a ValidationError for a duplicate name' do
    stub_request(:post, "#{yards_url}?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['Name has already been taken'] }.to_json, headers: json)

    expect { client.create_listing_play_yard(listing_id: 1, params: { name: 'Small yard', capacity: 6 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'patches a yard' do
    stub_request(:patch, "#{yards_url}/2?access_token=#{api_key}")
      .with(body: { calm_dogs_only: true }.to_json)
      .to_return(status: 200, body: { id: 2, calm_dogs_only: true }.to_json, headers: json)

    expect(client.patch_listing_play_yard(listing_id: 1, play_yard_id: 2, params: { calm_dogs_only: true })['id'])
      .to eq(2)
  end

  it 'deletes a yard' do
    stub_request(:delete, "#{yards_url}/2?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_listing_play_yard(listing_id: 1, play_yard_id: 2)).to be(true)
  end

  it 'lists placements for a rotation' do
    stub_request(:get, assignments_url)
      .with(query: { access_token: api_key, date: '2026-12-01', from: '09:00', to: '11:00' })
      .to_return(status: 200, body: [{ id: 8, warnings: %w[over_capacity size] }].to_json, headers: json)

    assignments = client.get_listing_playgroup_assignments(
      listing_id: 1, params: { date: '2026-12-01', from: '09:00', to: '11:00' }
    )
    expect(assignments.first).to be_a(PlaygroupAssignment)
    expect(assignments.first['warnings']).to eq(%w[over_capacity size])
  end

  it 'places a dog' do
    params = { reservation_id: 4, pet_id: 3, play_yard_id: 2, starts_at: '2026-12-01T09:00:00+13:00',
               ends_at: '2026-12-01T10:00:00+13:00' }
    stub_request(:post, "#{assignments_url}?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 8, warnings: [] }.to_json, headers: json)

    expect(client.create_listing_playgroup_assignment(listing_id: 1, params: params)['warnings']).to eq([])
  end

  it 'raises a ResourceNotFoundError for a stay that is not checked in' do
    stub_request(:post, "#{assignments_url}?access_token=#{api_key}").to_return(status: 404, body: '{}')

    expect { client.create_listing_playgroup_assignment(listing_id: 1, params: { reservation_id: 4 }) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'moves a dog to another yard' do
    stub_request(:patch, "#{assignments_url}/8?access_token=#{api_key}")
      .with(body: { play_yard_id: 5 }.to_json)
      .to_return(status: 200, body: { id: 8, play_yard_id: 5 }.to_json, headers: json)

    assignment = client.patch_listing_playgroup_assignment(listing_id: 1, playgroup_assignment_id: 8, play_yard_id: 5)
    expect(assignment['play_yard_id']).to eq(5)
  end

  it 'takes a dog out' do
    stub_request(:delete, "#{assignments_url}/8?access_token=#{api_key}").to_return(status: 204)

    expect(client.delete_listing_playgroup_assignment(listing_id: 1, playgroup_assignment_id: 8)).to be(true)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_play_yards(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_play_yard(listing_id: 1, play_yard_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_play_yard(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_listing_play_yard(listing_id: 1, play_yard_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_play_yard(listing_id: '', play_yard_id: 2) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_playgroup_assignments(listing_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.create_listing_playgroup_assignment(listing_id: '', params: {}) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.patch_listing_playgroup_assignment(listing_id: 1, playgroup_assignment_id: 8, play_yard_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.delete_listing_playgroup_assignment(listing_id: 1, playgroup_assignment_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
