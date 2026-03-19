require 'spec_helper'

describe UpwoofListings::DSL::Breeds do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_breeds' do
    it 'returns an array of breeds' do
      stub_request(:get, "#{base_url}/breeds/?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, name: 'Golden Retriever' }].to_json, headers: { 'Content-Type' => 'application/json' })

      breeds = client.get_breeds
      expect(breeds).to be_a(Array)
      expect(breeds.first).to be_a(Breed)
      expect(breeds.first['name']).to eq('Golden Retriever')
    end
  end

  describe '#get_breed' do
    it 'returns a breed' do
      stub_request(:get, "#{base_url}/breeds/1?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 1, name: 'Golden Retriever' }.to_json, headers: { 'Content-Type' => 'application/json' })

      breed = client.get_breed(id: 1)
      expect(breed).to be_a(Breed)
      expect(breed['name']).to eq('Golden Retriever')
    end

    it 'raises ArgumentError when ID is blank' do
      expect { client.get_breed(id: nil) }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_breed' do
    it 'creates a breed' do
      params = { name: 'Poodle', animal_type_id: 1 }
      stub_request(:post, "#{base_url}/breeds/?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, name: 'Poodle', animal_type_id: 1 }.to_json, headers: { 'Content-Type' => 'application/json' })

      breed = client.create_breed(params: params)
      expect(breed).to be_a(Breed)
      expect(breed['name']).to eq('Poodle')
    end
  end

  describe '#update_breed' do
    it 'updates a breed' do
      params = { name: 'Toy Poodle' }
      stub_request(:put, "#{base_url}/breeds/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, name: 'Toy Poodle' }.to_json, headers: { 'Content-Type' => 'application/json' })

      breed = client.update_breed(id: 2, params: params)
      expect(breed).to be_a(Breed)
      expect(breed['name']).to eq('Toy Poodle')
    end
  end

  describe '#patch_breed' do
    it 'partially updates a breed' do
      params = { name: 'Toy Poodle Patch' }
      stub_request(:patch, "#{base_url}/breeds/2?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: 2, name: 'Toy Poodle Patch' }.to_json, headers: { 'Content-Type' => 'application/json' })

      breed = client.patch_breed(id: 2, params: params)
      expect(breed).to be_a(Breed)
      expect(breed['name']).to eq('Toy Poodle Patch')
    end
  end

  describe '#delete_breed' do
    it 'deletes a breed' do
      stub_request(:delete, "#{base_url}/breeds/2?access_token=#{api_key}")
        .to_return(status: 204)

      expect(client.delete_breed(id: 2)).to be true
    end
  end
end
