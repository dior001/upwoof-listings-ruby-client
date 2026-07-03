require 'spec_helper'

describe UpwoofListings::DSL::Reviews do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_listing_reviews' do
    it 'returns an array of reviews' do
      stub_request(:get, "#{base_url}/listings/1/reviews?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, rating: 5, body: 'Great stay' }].to_json,
                   headers: { 'Content-Type' => 'application/json' })

      reviews = client.get_listing_reviews(listing_id: 1)
      expect(reviews).to be_a(Array)
      expect(reviews.first).to be_a(Review)
      expect(reviews.first['rating']).to eq(5)
    end

    it 'raises an ArgumentError when the listing id is blank' do
      expect { client.get_listing_reviews(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_reservation_review' do
    it 'creates a review' do
      params = { rating: 4, body: 'Lovely' }
      stub_request(:post, "#{base_url}/reservations/1/review?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 2, rating: 4, reservation_id: 1 }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      review = client.create_reservation_review(reservation_id: 1, params: params)
      expect(review).to be_a(Review)
      expect(review['rating']).to eq(4)
    end

    it 'raises an ArgumentError when the reservation id is blank' do
      expect do
        client.create_reservation_review(reservation_id: '', params: { rating: 5 })
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
