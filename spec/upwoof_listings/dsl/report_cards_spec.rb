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
end
