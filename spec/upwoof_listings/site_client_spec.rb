# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::SiteClient do
  let(:client) { described_class.new('uwsite_abc') }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:json) { { 'Content-Type' => 'application/json' } }
  let(:auth) { { 'Authorization' => 'Bearer uwsite_abc' } }

  it 'refuses a blank site token' do
    expect { described_class.new('') }.to raise_error(ArgumentError)
  end

  it 'gets the site config with the token as a bearer header, never in the URL' do
    stub = stub_request(:get, "#{base_url}/site")
           .with(headers: auth).to_return(status: 200, headers: json, body: { theme: 'modern' }.to_json)

    expect(client.get_site_config).to be_a(SiteConfig)
    expect(stub).to have_been_requested
  end

  it 'gets the listing and its accommodations' do
    stub_request(:get, "#{base_url}/site/listing").with(headers: auth)
                                                  .to_return(status: 200, headers: json, body: { name: 'Paws' }.to_json)
    stub_request(:get, "#{base_url}/site/accommodations").with(headers: auth)
                                                         .to_return(status: 200, headers: json,
                                                                    body: [{ id: 2, name: 'Suite' }].to_json)

    expect(client.get_site_listing['name']).to eq('Paws')
    expect(client.get_site_accommodations.first).to be_a(SiteAccommodation)
  end

  it 'gets a page of reviews' do
    stub_request(:get, "#{base_url}/site/reviews?page=2")
      .with(headers: auth)
      .to_return(status: 200, headers: json, body: { page: 2, reviews: [], total_pages: 2 }.to_json)

    expect(client.get_site_reviews(page: 2)['total_pages']).to eq(2)
  end

  it 'gets availability' do
    stub_request(:get, "#{base_url}/site/availability?check_in=2026-12-07&check_out=2026-12-09&dogs=1")
      .with(headers: auth)
      .to_return(status: 200, headers: json, body: { nights: 2, options: [] }.to_json)

    result = client.get_site_availability(params: { check_in: '2026-12-07', check_out: '2026-12-09', dogs: 1 })
    expect(result['nights']).to eq(2)
  end

  it "sends a booking request with the visitor's address" do
    body = { check_in: '2026-12-07', check_out: '2026-12-09', accommodation_id: 2, accepted_terms: true }
    stub_request(:post, "#{base_url}/site/booking_requests")
      .with(body: body.to_json, headers: auth.merge('X-Visitor-IP' => '198.51.100.7'))
      .to_return(status: 201, headers: json, body: { reference: 'R-1', status: 'awaiting_review' }.to_json)

    request = client.create_site_booking_request(params: body, visitor_ip: '198.51.100.7')
    expect(request).to be_a(SiteBookingRequest)
    expect(request['status']).to eq('awaiting_review')
  end

  it 'raises a ValidationError with the refusal code' do
    stub_request(:post, "#{base_url}/site/booking_requests")
      .to_return(status: 422, headers: json, body: { error: 'unavailable', message: 'Fully booked' }.to_json)

    expect { client.create_site_booking_request(params: {}) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.body['error']).to eq('unavailable') }
  end

  it 'sends an inquiry' do
    stub_request(:post, "#{base_url}/site/inquiries").with(headers: auth)
                                                     .to_return(status: 201, headers: json,
                                                                body: { status: 'received' }.to_json)

    expect(client.create_site_inquiry(params: { first_name: 'Ana' })['status']).to eq('received')
  end

  it 'raises a ClientError for a bad token and a ResourceNotFoundError for a missing path', :aggregate_failures do
    stub_request(:get, "#{base_url}/site")
      .to_return(status: 401, headers: json, body: { error: 'unauthorized' }.to_json)
    stub_request(:get, "#{base_url}/site/listing").to_return(status: 404, headers: json, body: '{}')

    expect { client.get_site_config }.to raise_error(UpwoofListings::Errors::ClientError)
    expect { client.get_site_listing }.to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end
end
