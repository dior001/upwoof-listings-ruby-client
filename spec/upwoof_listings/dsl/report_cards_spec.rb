require 'spec_helper'

describe UpwoofListings::DSL::ReportCards do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }

  describe '#get_reservation_report_cards' do
    it 'returns an array of report cards' do
      stub_request(:get, "#{base_url}/reservations/1/report_cards?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 1, pet_id: 2, date: '2026-01-01' }].to_json,
                   headers: { 'Content-Type' => 'application/json' })

      report_cards = client.get_reservation_report_cards(reservation_id: 1)
      expect(report_cards).to be_a(Array)
      expect(report_cards.first).to be_a(ReportCard)
      expect(report_cards.first['pet_id']).to eq(2)
    end

    it 'raises an ArgumentError when the reservation id is blank' do
      expect do
        client.get_reservation_report_cards(reservation_id: '')
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe '#create_reservation_report_card' do
    it 'creates a report card for the reservation' do
      params = { pet_id: 2, date: '2026-01-01', mood: 'happy' }
      stub_request(:post, "#{base_url}/reservations/1/report_cards?access_token=#{api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, pet_id: 2, date: '2026-01-01', mood: 'happy' }.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      report_card = client.create_reservation_report_card(reservation_id: 1, params: params)
      expect(report_card).to be_a(ReportCard)
      expect(report_card['pet_id']).to eq(2)
    end

    it 'raises an ArgumentError when the reservation id is blank' do
      expect do
        client.create_reservation_report_card(reservation_id: '', params: {})
      end.to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end

  describe 'listing-wide report cards and photos' do
    let(:json) { { 'Content-Type' => 'application/json' } }
    let(:cards_url) { "#{base_url}/listings/1/report_cards" }

    it "lists a day's cards" do
      stub_request(:get, cards_url).with(query: { access_token: api_key, status: 'draft' })
                                   .to_return(status: 200, body: [{ id: 6, reservation_id: 4 }].to_json,
                                              headers: json)

      cards = client.get_listing_report_cards(listing_id: 1, params: { status: 'draft' })
      expect(cards.first).to be_a(ReportCard)
      expect(cards.first['reservation_id']).to eq(4)
    end

    it "starts today's drafts" do
      stub_request(:post, "#{cards_url}/start?access_token=#{api_key}")
        .with(body: { include_care_log: true }.to_json)
        .to_return(status: 201, body: { created_count: 3, date: '2026-12-01', skipped_count: 1 }.to_json, headers: json)

      result = client.start_listing_report_cards(listing_id: 1, include_care_log: true)
      expect(result.values_at('created_count', 'skipped_count')).to eq([3, 1])
    end

    it 'raises a ValidationError when report cards are off' do
      stub_request(:post, "#{cards_url}/start?access_token=#{api_key}")
        .with(body: { include_care_log: false }.to_json)
        .to_return(status: 422, body: { error: 'report_cards_disabled', message: 'Report cards are off' }.to_json,
                   headers: json)

      expect { client.start_listing_report_cards(listing_id: 1) }
        .to raise_error(UpwoofListings::Errors::ValidationError)
    end

    it "publishes today's drafts" do
      stub_request(:post, "#{cards_url}/publish?access_token=#{api_key}")
        .to_return(status: 201, body: { date: '2026-12-01', published_count: 3 }.to_json, headers: json)

      expect(client.publish_listing_report_cards(listing_id: 1)['published_count']).to eq(3)
    end

    it "lists a card's photos" do
      stub_request(:get, "#{base_url}/report_cards/6/photos?access_token=#{api_key}")
        .to_return(status: 200, body: [{ id: 12, shared: false, photo_share_id: nil }].to_json, headers: json)

      photos = client.get_report_card_photos(report_card_id: 6)
      expect(photos.first).to be_a(ReportCardPhoto)
      expect(photos.first['shared']).to be(false)
    end

    it 'shares and unshares a photo' do
      url = "#{base_url}/report_cards/6/photos/12/share?access_token=#{api_key}"
      stub_request(:post, url).to_return(status: 201, body: { id: 12, shared: true, photo_share_id: 30 }.to_json,
                                         headers: json)
      stub_request(:delete, url).to_return(status: 204)

      expect(client.share_report_card_photo(report_card_id: 6, photo_id: 12)['photo_share_id']).to eq(30)
      expect(client.unshare_report_card_photo(report_card_id: 6, photo_id: 12)).to be(true)
    end

    it 'raises an ArgumentError for blank ids' do
      expect { client.get_listing_report_cards(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.start_listing_report_cards(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.publish_listing_report_cards(listing_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.get_report_card_photos(report_card_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.share_report_card_photo(report_card_id: 6, photo_id: '') }
        .to raise_error(ArgumentError, 'ID cannot be blank')
      expect { client.unshare_report_card_photo(report_card_id: '', photo_id: 12) }
        .to raise_error(ArgumentError, 'ID cannot be blank')
    end
  end
end
