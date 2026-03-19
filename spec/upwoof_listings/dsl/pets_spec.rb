require 'spec_helper'

describe UpwoofListings::DSL::Pets do
  # GET /pets
  describe '#get_pets' do
    it 'returns an array of pets' do
      VCR.use_cassette('get_pets') do
        pets = UpwoofListings.client.get_pets
        expect(pets).to be_a(Array)
        expect(pets.first).to be_a(Pet)
      end
    end
  end

  # GET /pets/{id}
  describe '#get_pet' do
    it 'returns a pet' do
      id = VCR.use_cassette('get_pets') do
        pets = UpwoofListings.client.get_pets
        pets.first['id']
      end

      VCR.use_cassette('get_pet') do
        expect(UpwoofListings.client.get_pet(id: id)).to be_a(Pet)
      end
    end
  end

  # POST /pets
  describe '#create_pet' do
    it 'creates a pet' do
      params = { name: 'Fido', animal_type_id: 1, breed_id: 1, customer_id: 1 }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/pets/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, name: 'Fido' }.to_json, headers: { 'Content-Type' => 'application/json' })

      pet = UpwoofListings.client.create_pet(params: params)
      expect(pet).to be_a(Pet)
    end
  end

  # PUT /pets/{id}
  describe '#update_pet' do
    it 'updates a pet' do
      id = 1
      params = { name: 'Fido Updated' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/pets/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Fido Updated' }.to_json, headers: { 'Content-Type' => 'application/json' })

      pet = UpwoofListings.client.update_pet(id: id, params: params)
      expect(pet).to be_a(Pet)
    end
  end

  # PATCH /pets/{id}
  describe '#patch_pet' do
    it 'partially updates a pet' do
      id = 1
      params = { name: 'Fido Patched' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/pets/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, name: 'Fido Patched' }.to_json, headers: { 'Content-Type' => 'application/json' })

      pet = UpwoofListings.client.patch_pet(id: id, params: params)
      expect(pet).to be_a(Pet)
    end
  end

  # DELETE /pets/{id}
  describe '#delete_pet' do
    it 'deletes a pet' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/pets/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_pet(id: id)).to be true
    end
  end
end
