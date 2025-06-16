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
        expect(UpwoofListings.client.get_pet(id:)).to be_a(Pet)
      end
    end
  end
end
