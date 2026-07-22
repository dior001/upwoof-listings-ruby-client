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
end
