require 'spec_helper'

describe UpwoofListings::DSL::AccommodationTypes do
  describe '#get_accommodation_types' do
    it 'returns an array of accommodation types' do
      VCR.use_cassette('get_accommodation_types') do
        accommodation_types = UpwoofListings.client.get_accommodation_types
        expect(accommodation_types).to be_a(Array)
        expect(accommodation_types.first).to be_a(AccommodationType) if accommodation_types.any?
      end
    end
  end
end
