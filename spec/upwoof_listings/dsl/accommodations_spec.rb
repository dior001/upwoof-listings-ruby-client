require 'spec_helper'

describe UpwoofListings::DSL::Accommodations do
  # GET /accommodations
  describe '#get_accommodations' do
    it 'returns an array of accommodations' do
      VCR.use_cassette('get_accommodations') do
        accommodations = UpwoofListings.client.get_accommodations
        expect(accommodations).to be_a(Array)
        expect(accommodations.first).to be_a(Accommodation)
      end
    end

    it 'passes query parameters' do
      params = { listing_id: 123 }
      stub_request(:get, "#{UpwoofListings.url.chomp('/')}/accommodations/?access_token=#{UpwoofListings.api_key}&listing_id=123")
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      UpwoofListings.client.get_accommodations(params: params)
    end
  end

  # GET /accommodations/{id}
  describe '#get_accommodation' do
    it 'returns an accommodation' do
      id = VCR.use_cassette('get_accommodations') do
        accommodations = UpwoofListings.client.get_accommodations
        accommodations.first['id']
      end

      VCR.use_cassette('get_accommodation') do
        expect(UpwoofListings.client.get_accommodation(id: id)).to be_a(Accommodation)
      end
    end
  end

  # POST /accommodations
  describe '#create_accommodation' do
    it 'creates an accommodation' do
      params = { name: 'Suite 1', accommodation_type_id: 1 }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/accommodations/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, name: 'Suite 1' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation = UpwoofListings.client.create_accommodation(params: params)
      expect(accommodation).to be_a(Accommodation)
    end
  end

  # PUT /accommodations/{id}
  describe '#update_accommodation' do
    it 'updates an accommodation' do
      id = 1
      params = { name: 'Suite 1 Updated' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/accommodations/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Suite 1 Updated' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation = UpwoofListings.client.update_accommodation(id: id, params: params)
      expect(accommodation).to be_a(Accommodation)
    end
  end

  # PATCH /accommodations/{id}
  describe '#patch_accommodation' do
    it 'partially updates an accommodation' do
      id = 1
      params = { name: 'Suite 1 Patched' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/accommodations/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Suite 1 Patched' }.to_json, headers: { 'Content-Type' => 'application/json' })

      accommodation = UpwoofListings.client.patch_accommodation(id: id, params: params)
      expect(accommodation).to be_a(Accommodation)
    end
  end

  # DELETE /accommodations/{id}
  describe '#delete_accommodation' do
    it 'deletes an accommodation' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/accommodations/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_accommodation(id: id)).to be true
    end
  end
end
