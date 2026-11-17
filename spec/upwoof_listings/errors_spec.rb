require 'spec_helper'

describe UpwoofListings::Errors do
  # A minimal stand-in for a Faraday::Response, exposing the two methods the
  # error classes read.
  let(:response) { double('response', status: 422, body: 'Unprocessable Entity') }

  describe UpwoofListings::Errors::ClientError do
    subject(:error) { described_class.new(response: response) }

    it 'exposes the originating response' do
      expect(error.response).to be(response)
    end

    it 'builds a message from the response status and body' do
      expect(error.message).to eq('HTTP 422: Unprocessable Entity')
    end

    it 'is a StandardError' do
      expect(error).to be_a(StandardError)
    end
  end

  describe UpwoofListings::Errors::ResourceNotFoundError do
    subject(:error) { described_class.new(response: response) }

    it 'inherits the ClientError behaviour' do
      expect(error).to be_a(UpwoofListings::Errors::ClientError)
      expect(error.response).to be(response)
      expect(error.message).to eq('HTTP 422: Unprocessable Entity')
    end
  end

  describe 'errors' do
    it 'reads the API error messages from a JSON body' do
      json = double('response', status: 422, body: { errors: ['Dates unavailable'] }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: json).errors).to eq(['Dates unavailable'])
    end

    it 'wraps a single message in an array' do
      json = double('response', status: 422, body: { errors: 'Dates unavailable' }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: json).errors).to eq(['Dates unavailable'])
    end

    it 'is empty for a body that is not JSON or has no errors or message' do
      expect(UpwoofListings::Errors::ClientError.new(response: response).errors).to eq([])
      no_errors = double('response', status: 400, body: { error: 'bad request' }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: no_errors).errors).to eq([])
      list = double('response', status: 400, body: ['Bad'].to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: list).errors).to eq([])
    end

    it "falls back to the body's single message" do
      json = double('response', status: 422,
                                body: { error: 'unprocessable entity', message: 'Insufficient store credit' }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: json).errors).to eq(['Insufficient store credit'])
    end

    it 'lists the messages of an errors hash' do
      json = double('response', status: 422, body: { errors: { '7' => 'is not a number' } }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: json).errors).to eq(['is not a number'])
    end
  end

  describe 'body' do
    it 'is the parsed JSON body' do
      json = double('response', status: 422, body: { unknown_custom_field_ids: ['9'], errors: {} }.to_json)
      expect(UpwoofListings::Errors::ClientError.new(response: json).body)
        .to eq('unknown_custom_field_ids' => ['9'], 'errors' => {})
    end

    it 'is nil for a body that is not JSON' do
      expect(UpwoofListings::Errors::ClientError.new(response: response).body).to be_nil
    end
  end

  describe UpwoofListings::Errors::ValidationError do
    it 'is a ClientError' do
      expect(described_class.new(response: response)).to be_a(UpwoofListings::Errors::ClientError)
    end
  end
end
