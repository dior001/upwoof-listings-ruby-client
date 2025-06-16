require 'spec_helper'

describe UpwoofListings::DSL::Accommodations do
  # GET /accommodations
  describe '#get_accommodations' do
    it 'returns an array of accommodations' do
      VCR.use_cassette('get_accommodations') do
        accommodations = UpwoofListings.client.get_accommodations
        expect(accommodations).to be_a(Array)
        expect(accommodations.first).to be_a(Accommodation)
      end
    end
  end

  # GET /accommodations/{id}
  describe '#get_accommodation' do
    it 'returns an accommodation' do
      id = VCR.use_cassette('get_accommodations') do
        accommodations = UpwoofListings.client.get_accommodations
        accommodations.first['id']
      end

      VCR.use_cassette('get_accommodation') do
        expect(UpwoofListings.client.get_accommodation(id:)).to be_a(Accommodation)
      end
    end
  end
end
