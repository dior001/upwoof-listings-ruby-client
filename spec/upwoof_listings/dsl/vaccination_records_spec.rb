require 'spec_helper'

describe UpwoofListings::DSL::VaccinationRecords do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_pet_vaccination_records' do
    it 'returns an array of vaccination records' do
      stub_request(:get, "#{base_url}/pets/1/vaccination_records?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, vaccine_name: 'rabies', pet_id: 1 }].to_json,
                   headers: { 'Content-Type' => 'application/json' })

      records = client.get_pet_vaccination_records(pet_id: 1)
      expect(records).to be_a(Array)
      expect(records.first).to be_a(VaccinationRecord)
      expect(records.first['vaccine_name']).to eq('rabies')
    end

    it 'raises an ArgumentError when the pet id is blank' do
      expect do
        client.get_pet_vaccination_records(pet_id: '')
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_pet_vaccination_record' do
    it 'creates a vaccination record for the pet' do
      params = { vaccine_name: 'rabies', administered_on: '2026-01-01' }
      stub_request(:post, "#{base_url}/pets/1/vaccination_records?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, vaccine_name: 'rabies', pet_id: 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      record = client.create_pet_vaccination_record(pet_id: 1, params: params)
      expect(record).to be_a(VaccinationRecord)
      expect(record['pet_id']).to eq(1)
    end

    it 'raises an ArgumentError when the pet id is blank' do
      expect do
        client.create_pet_vaccination_record(pet_id: '', params: {})
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
