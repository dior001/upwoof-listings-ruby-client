require 'spec_helper'

describe UpwoofListings::Client do
  subject(:client) { UpwoofListings::Client.new }

  # The client concatenates the configured base URL (which ends in a slash) with
  # the path as-is, so the DSL passes paths WITHOUT a leading slash.
  let(:base_url) { UpwoofListings.url }
  let(:api_key) { UpwoofListings.api_key }

  describe '#request' do
    it 'raises ArgumentError for an unsupported HTTP method' do
      expect { client.request(:options, 'users') }
        .to raise_error(ArgumentError, /Unsupported method :options/)
    end

    it 'returns the response on a 2xx status' do
      stub_request(:get, "#{base_url}ping?access_token=#{api_key}")
        .to_return(status: 200, body: 'ok')

      response = client.request(:get, 'ping')
      expect(response.status).to eq(200)
    end

    it 'merges query params into the URL on GET' do
      stub = stub_request(:get, "#{base_url}users?access_token=#{api_key}&page=2")
             .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })

      client.request(:get, 'users', { page: 2 })
      expect(stub).to have_been_requested
    end

    it 'sends a JSON body when the Accept header is application/json' do
      payload = { name: 'Rex' }
      stub = stub_request(:post, "#{base_url}pets?access_token=#{api_key}")
             .with(body: payload.to_json)
             .to_return(status: 201, body: '{}', headers: { 'Content-Type' => 'application/json' })

      client.request(:post, 'pets', payload)
      expect(stub).to have_been_requested
    end

    it 'passes the raw query through as the body when the Accept header is not JSON' do
      headers = { 'Accept' => 'multipart/form-data' }
      stub = stub_request(:post, "#{base_url}uploads?access_token=#{api_key}")
             .with(body: { 'file' => 'data' })
             .to_return(status: 201, body: '', headers: { 'Content-Type' => 'application/json' })

      client.request(:post, 'uploads', { file: 'data' }, headers)
      expect(stub).to have_been_requested
    end

    it 'raises ResourceNotFoundError on a 404' do
      stub_request(:get, "#{base_url}users/999?access_token=#{api_key}")
        .to_return(status: 404, body: 'Not Found')

      expect { client.request(:get, 'users/999') }
        .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
    end

    it 'raises ClientError on any other non-success status' do
      stub_request(:get, "#{base_url}boom?access_token=#{api_key}")
        .to_return(status: 500, body: 'Server Error')

      expect { client.request(:get, 'boom') }
        .to raise_error(UpwoofListings::Errors::ClientError, /HTTP 500/)
    end
  end
end
