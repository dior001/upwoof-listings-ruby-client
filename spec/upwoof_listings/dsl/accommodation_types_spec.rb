require 'spec_helper'

describe UpwoofListings::DSL::AccommodationTypes do
  describe '#get_accommodation_types' do
    it 'returns an array of accommodation types' do
      VCR.use_cassette('get_accommodation_types') do
        accommodation_types = UpwoofListings.client.get_accommodation_types
        expect(accommodation_types).to be_a(Array)
        expect(accommodation_types.first).to be_a(AccommodationType) if accommodation_types.any?
      end
    end
  end

  # GET /accommodation_types/{id}
  describe '#get_accommodation_type' do
    it 'returns an accommodation type' do
      id = 1
      stub_request(:get, "#{UpwoofListings.url.chomp('/')}/accommodation_types/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 200, body: { id: id, name: 'Standard' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation_type = UpwoofListings.client.get_accommodation_type(id: id)
      expect(accommodation_type).to be_a(AccommodationType)
    end
  end

  # POST /accommodation_types
  describe '#create_accommodation_type' do
    it 'creates an accommodation type' do
      params = { name: 'Deluxe' }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/accommodation_types/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, name: 'Deluxe' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation_type = UpwoofListings.client.create_accommodation_type(params: params)
      expect(accommodation_type).to be_a(AccommodationType)
    end
  end

  # PUT /accommodation_types/{id}
  describe '#update_accommodation_type' do
    it 'updates an accommodation type' do
      id = 2
      params = { name: 'Super Deluxe' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/accommodation_types/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Super Deluxe' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation_type = UpwoofListings.client.update_accommodation_type(id: id, params: params)
      expect(accommodation_type).to be_a(AccommodationType)
    end
  end

  # PATCH /accommodation_types/{id}
  describe '#patch_accommodation_type' do
    it 'partially updates an accommodation type' do
      id = 2
      params = { name: 'Ultra Deluxe' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/accommodation_types/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Ultra Deluxe' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation_type = UpwoofListings.client.patch_accommodation_type(id: id, params: params)
      expect(accommodation_type).to be_a(AccommodationType)
    end
  end

  # DELETE /accommodation_types/{id}
  describe '#delete_accommodation_type' do
    it 'deletes an accommodation type' do
      id = 2
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/accommodation_types/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_accommodation_type(id: id)).to be true
    end
  end
end
