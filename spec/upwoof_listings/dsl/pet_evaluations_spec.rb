# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::PetEvaluations do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  describe '#get_pet_evaluations' do
    it 'lists evaluations with the filters in the query string' do
      stub_request(:get, "#{base_url}/pet_evaluations")
        .with(query: { access_token: api_key, result: 'passed', pet_id: '3' })
        .to_return(status: 200, body: [{ id: 1, evaluation_type: 'temperament' }].to_json, headers: json)

      evaluations = client.get_pet_evaluations(params: { result: 'passed', pet_id: 3 })
      expect(evaluations.first).to be_a(PetEvaluation)
      expect(evaluations.first['evaluation_type']).to eq('temperament')
    end
  end

  describe '#get_pet_evaluation' do
    it 'returns an evaluation' do
      stub_request(:get, "#{base_url}/pet_evaluations/5?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 5 }.to_json, headers: json)

      expect(client.get_pet_evaluation(id: 5)['id']).to eq(5)
    end

    it 'raises ResourceNotFoundError for an evaluation elsewhere' do
      stub_request(:get, "#{base_url}/pet_evaluations/9?access_token=#{api_key}").to_return(status: 404, body: '{}')

      expect { client.get_pet_evaluation(id: 9) }.to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
    end

    it 'raises an ArgumentError when the id is blank' do
      expect { client.get_pet_evaluation(id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_reservation_pet_evaluation' do
    it 'records a result' do
      params = { pet_id: 3, result: 'passed', evaluation_type: 'meet_and_greet' }
      stub_request(:post, "#{base_url}/reservations/7/pet_evaluations?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, reservation_id: 7 }.to_json, headers: json)

      expect(client.create_reservation_pet_evaluation(reservation_id: 7, params: params)['reservation_id']).to eq(7)
    end

    it 'raises a ValidationError with the message' do
      stub_request(:post, "#{base_url}/reservations/7/pet_evaluations?access_token=#{api_key}")
        .to_return(status: 422, body: { error: 'unprocessable entity', message: 'Expires on is invalid' }.to_json)

      expect { client.create_reservation_pet_evaluation(reservation_id: 7, params: {}) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |e| expect(e.errors).to eq(['Expires on is invalid']) }
    end

    it 'raises an ArgumentError when the reservation id is blank' do
      expect { client.create_reservation_pet_evaluation(reservation_id: '', params: {}) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end

describe UpwoofListings::DSL::Pets do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  describe '#deactivate_pet' do
    it 'marks the pet inactive' do
      stub_request(:post, "#{base_url}/pets/4/deactivation?access_token=#{api_key}")
        .with(body: { deactivation_reason: 'passed_away' }.to_json)
        .to_return(status: 200, body: { id: 4, status: 'inactive' }.to_json, headers: json)

      pet = client.deactivate_pet(id: 4, deactivation_reason: 'passed_away')
      expect(pet).to be_a(Pet)
      expect(pet['status']).to eq('inactive')
    end

    it 'raises a ValidationError when the pet is already inactive' do
      stub_request(:post, "#{base_url}/pets/4/deactivation?access_token=#{api_key}")
        .to_return(status: 422, body: { error: 'unprocessable entity', message: 'Pet is already inactive' }.to_json)

      expect { client.deactivate_pet(id: 4, deactivation_reason: 'other') }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it 'raises an ArgumentError for a blank id or reason' do
      expect { client.deactivate_pet(id: '', deactivation_reason: 'other') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.deactivate_pet(id: 4, deactivation_reason: '') }
        .to raise_error(ArgumentError, 'Deactivation reason cannot be blank')
    end
  end

  describe '#reactivate_pet' do
    it 'makes the pet active again' do
      stub_request(:delete, "#{base_url}/pets/4/deactivation?access_token=#{api_key}")
        .to_return(status: 200, body: { id: 4, status: 'active' }.to_json, headers: json)

      expect(client.reactivate_pet(id: 4)['status']).to eq('active')
    end

    it 'raises an ArgumentError when the id is blank' do
      expect { client.reactivate_pet(id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe 'booking an inactive pet' do
    it 'raises a ValidationError naming the pet' do
      stub_request(:post, "#{base_url}/reservations/?access_token=#{api_key}")
        .to_return(status: 422, body: { error: 'unprocessable entity',
                                        message: "Inactive pets can't be booked: Rex" }.to_json)

      expect { client.create_reservation(params: { pet_id: 4 }) }
        .to raise_error(UpwoofListings::Errors::ValidationError) { |e| expect(e.errors).to eq(["Inactive pets can't be booked: Rex"]) }
    end
  end
end
