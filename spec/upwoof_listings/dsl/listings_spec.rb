require 'spec_helper'

describe UpwoofListings::DSL::Listings do
  # GET /listings
  describe '#get_listings' do
    it 'returns an array of listings' do
      VCR.use_cassette('get_listings') do
        listings = UpwoofListings.client.get_listings
        expect(listings).to be_a(Array)
        expect(listings.first).to be_a(Listing)
      end
    end
  end

  # GET /listings/{id}
  describe '#get_listing' do
    it 'returns a listing' do
      id = VCR.use_cassette('get_listings') do
        listings = UpwoofListings.client.get_listings
        listings.first['id']
      end

      VCR.use_cassette('get_listing') do
        expect(UpwoofListings.client.get_listing(id: id)).to be_a(Listing)
      end
    end
  end

  # POST /listings
  describe '#create_listing' do
    it 'creates a listing' do
      params = { name: 'New Listing' }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/listings/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, name: 'New Listing' }.to_json, headers: { 'Content-Type' => 'application/json' })

      listing = UpwoofListings.client.create_listing(params: params)
      expect(listing).to be_a(Listing)
      expect(listing['name']).to eq('New Listing')
    end
  end

  # PUT /listings/{id}
  describe '#update_listing' do
    it 'updates a listing' do
      id = 1
      params = { name: 'Updated Listing' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/listings/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Updated Listing' }.to_json, headers: { 'Content-Type' => 'application/json' })

      listing = UpwoofListings.client.update_listing(id: id, params: params)
      expect(listing).to be_a(Listing)
      expect(listing['name']).to eq('Updated Listing')
    end
  end

  # PATCH /listings/{id}
  describe '#patch_listing' do
    it 'partially updates a listing' do
      id = 1
      params = { name: 'Patched Listing' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/listings/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Patched Listing' }.to_json, headers: { 'Content-Type' => 'application/json' })

      listing = UpwoofListings.client.patch_listing(id: id, params: params)
      expect(listing).to be_a(Listing)
      expect(listing['name']).to eq('Patched Listing')
    end
  end

  # DELETE /listings/{id}
  describe '#delete_listing' do
    it 'deletes a listing' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/listings/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_listing(id: id)).to be true
    end
  end

  # GET /listings/{id}/capacity
  describe '#get_listing_capacity' do
    let(:base_url) { UpwoofListings.url.chomp('/') }
    let(:api_key) { UpwoofListings.api_key }

    it 'returns the capacity for a listing' do
      id = 1
      stub_request(:get, "#{base_url}/listings/#{id}/capacity?access_token=#{api_key}")
        .to_return(status: 200,
                   body: { current_dogs: 2, max_dogs: 5, current_cats: 1, max_cats: 3,
                           available_dogs: 3, available_cats: 2 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      capacity = UpwoofListings.client.get_listing_capacity(listing_id: id)
      expect(capacity['current_dogs']).to eq(2)
      expect(capacity['available_cats']).to eq(2)
    end

    it 'passes a date query parameter when given' do
      id = 1
      stub_request(:get, "#{base_url}/listings/#{id}/capacity?access_token=#{api_key}&date=2026-01-01")
        .to_return(status: 200, body: { current_dogs: 0 }.to_json, headers: { 'Content-Type' => 'application/json' })

      UpwoofListings.client.get_listing_capacity(listing_id: id, date: '2026-01-01')
    end

    it 'raises an ArgumentError when the listing id is blank' do
      expect do
        UpwoofListings.client.get_listing_capacity(listing_id: '')
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
