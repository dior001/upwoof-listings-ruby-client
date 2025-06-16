require 'spec_helper'

describe UpwoofListings::DSL::CreditNotes do
  # GET /credit_notes
  describe '#get_credit_notes', :skip do
    it 'returns an array of credit notes' do
      VCR.use_cassette('get_credit_notes') do
        credit_notes = UpwoofListings.client.get_credit_notes
        expect(credit_notes).to be_a(Array)
        expect(credit_notes.first).to be_a(CreditNote)
      end
    end
  end

  # GET /credit_notes/{id}
  describe '#get_credit_note', :skip do
    it 'returns a credit note' do
      id = VCR.use_cassette('get_credit_notes') do
        credit_notes = UpwoofListings.client.get_credit_notes
        credit_notes.first['id']
      end

      VCR.use_cassette('get_credit_note') do
        expect(UpwoofListings.client.get_credit_note(id:)).to be_a(CreditNote)
      end
    end
  end
end
