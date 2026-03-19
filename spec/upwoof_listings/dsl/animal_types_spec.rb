require 'spec_helper'

describe UpwoofListings::DSL::AnimalTypes do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_animal_types' do
    it 'returns an array of animal types' do
      stub_request(:get, "#{base_url}/animal_types/?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, name: 'Dog' }].to_json, headers: { 'Content-Type' => 'application/json' })

      animal_types = client.get_animal_types
      expect(animal_types).to be_a(Array)
      expect(animal_types.first).to be_a(AnimalType)
      expect(animal_types.first['name']).to eq('Dog')
    end
  end

  describe '#get_animal_type' do
    it 'returns an animal type' do
      stub_request(:get, "#{base_url}/animal_types/1?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 1, name: 'Dog' }.to_json, headers: { 'Content-Type' => 'application/json' })

      animal_type = client.get_animal_type(id: 1)
      expect(animal_type).to be_a(AnimalType)
      expect(animal_type['name']).to eq('Dog')
    end

    it 'raises ArgumentError when ID is blank' do
      expect { client.get_animal_type(id: nil) }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_animal_type' do
    it 'creates an animal type' do
      params = { name: 'Cat' }
      stub_request(:post, "#{base_url}/animal_types/?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, name: 'Cat' }.to_json, headers: { 'Content-Type' => 'application/json' })

      animal_type = client.create_animal_type(params: params)
      expect(animal_type).to be_a(AnimalType)
      expect(animal_type['name']).to eq('Cat')
    end
  end

  describe '#update_animal_type' do
    it 'updates an animal type' do
      params = { name: 'Feline' }
      stub_request(:put, "#{base_url}/animal_types/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, name: 'Feline' }.to_json, headers: { 'Content-Type' => 'application/json' })

      animal_type = client.update_animal_type(id: 2, params: params)
      expect(animal_type).to be_a(AnimalType)
      expect(animal_type['name']).to eq('Feline')
    end
  end

  describe '#patch_animal_type' do
    it 'partially updates an animal type' do
      params = { name: 'Feline Patch' }
      stub_request(:patch, "#{base_url}/animal_types/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, name: 'Feline Patch' }.to_json, headers: { 'Content-Type' => 'application/json' })

      animal_type = client.patch_animal_type(id: 2, params: params)
      expect(animal_type).to be_a(AnimalType)
      expect(animal_type['name']).to eq('Feline Patch')
    end
  end

  describe '#delete_animal_type' do
    it 'deletes an animal type' do
      stub_request(:delete, "#{base_url}/animal_types/2?access_token=#{api_key}")
        .to_return(status: 204)

      expect(client.delete_animal_type(id: 2)).to be true
    end
  end
end
