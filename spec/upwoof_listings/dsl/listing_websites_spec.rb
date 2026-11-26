# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::ListingWebsites do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }
  let(:website_url) { "#{base_url}/listings/1/website?access_token=#{api_key}" }

  it "gets a listing's website" do
    stub_request(:get, website_url)
      .to_return(status: 200, headers: json, body: { id: 4, subdomain: 'happy-paws', theme: 'classic' }.to_json)

    website = client.get_listing_website(listing_id: 1)
    expect(website).to be_a(ListingWebsite)
    expect(website['subdomain']).to eq('happy-paws')
  end

  it 'raises a ResourceNotFoundError when the listing has no website' do
    stub_request(:get, website_url).to_return(status: 404, headers: json,
                                              body: { error: 'not_found', message: 'No website' }.to_json)

    expect { client.get_listing_website(listing_id: 1) }.to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it "changes a listing's website" do
    body = { theme: 'playful', palette: { primary: '#112233' }, bookings_enabled: false }
    stub_request(:patch, website_url).with(body: body.to_json)
                                     .to_return(status: 200, headers: json, body: { id: 4, theme: 'playful' }.to_json)

    expect(client.update_listing_website(listing_id: 1, params: body)['theme']).to eq('playful')
  end

  it 'raises a ValidationError when the domain is refused' do
    stub_request(:patch, website_url).to_return(status: 422, headers: json,
                                                body: { error: 'custom_domain_refused', message: 'Taken' }.to_json)

    expect { client.update_listing_website(listing_id: 1, params: { custom_domain: 'www.happy.com' }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |error| expect(error.errors).to eq(['Taken']) }
  end

  it 'refuses a blank listing id' do
    expect { client.get_listing_website(listing_id: nil) }.to raise_error(ArgumentError)
    expect { client.update_listing_website(listing_id: '', params: {}) }.to raise_error(ArgumentError)
  end
end
