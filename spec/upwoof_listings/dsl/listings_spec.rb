require 'spec_helper'

describe UpwoofListings::DSL::Listings do
  # GET /listings
  describe '#get_listings' do
    it 'returns an array of listings' do
      VCR.use_cassette('get_listings') do
        listings = UpwoofListings.client.get_listings
        expect(listings).to be_a(Array)
        expect(listings.first).to be_a(Listing)
      end
    end
  end

  # GET /listings/{id}
  describe '#get_listing' do
    it 'returns a listing' do
      id = VCR.use_cassette('get_listings') do
        listings = UpwoofListings.client.get_listings
        listings.first['id']
      end

      VCR.use_cassette('get_listing') do
        expect(UpwoofListings.client.get_listing(id:)).to be_a(Listing)
      end
    end
  end
end
