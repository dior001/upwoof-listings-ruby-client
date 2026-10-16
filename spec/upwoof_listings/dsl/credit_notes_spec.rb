require 'spec_helper'

describe UpwoofListings::DSL::CreditNotes do
  # GET /credit_notes
  describe '#get_credit_notes' do
    it 'returns an array of credit notes' do
      VCR.use_cassette('get_credit_notes') do
        credit_notes = UpwoofListings.client.get_credit_notes
        expect(credit_notes).to be_a(Array)
        expect(credit_notes.first).to be_a(CreditNote)
      end
    end
  end

  # GET /credit_notes/{id}
  describe '#get_credit_note' do
    it 'returns a credit note' do
      id = VCR.use_cassette('get_credit_notes') do
        credit_notes = UpwoofListings.client.get_credit_notes
        credit_notes.first['id']
      end

      VCR.use_cassette('get_credit_note') do
        expect(UpwoofListings.client.get_credit_note(id: id)).to be_a(CreditNote)
      end
    end
  end

  # POST /credit_notes
  describe '#create_credit_note' do
    it 'creates a credit note' do
      params = { invoice_id: 1, amount: 10.0 }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/credit_notes/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, credit_note_number: 'CN-1' }.to_json, headers: { 'Content-Type' => 'application/json' })

      credit_note = UpwoofListings.client.create_credit_note(params: params)
      expect(credit_note).to be_a(CreditNote)
    end
  end

  # PUT /credit_notes/{id}
  describe '#update_credit_note' do
    it 'updates a credit note' do
      id = 1
      params = { reason: 'correction' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/credit_notes/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, reason: 'correction' }.to_json, headers: { 'Content-Type' => 'application/json' })

      credit_note = UpwoofListings.client.update_credit_note(id: id, params: params)
      expect(credit_note).to be_a(CreditNote)
    end
  end

  # PATCH /credit_notes/{id}
  describe '#patch_credit_note' do
    it 'partially updates a credit note' do
      id = 1
      params = { reason: 'correction patch' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/credit_notes/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, reason: 'correction patch' }.to_json, headers: { 'Content-Type' => 'application/json' })

      credit_note = UpwoofListings.client.patch_credit_note(id: id, params: params)
      expect(credit_note).to be_a(CreditNote)
    end
  end

  # POST /credit_notes/{id}/void
  describe '#void_credit_note' do
    it 'voids a credit note' do
      id = 1
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/credit_notes/#{id}/void?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 200, body: { id: id, status: 'void' }.to_json, headers: { 'Content-Type' => 'application/json' })

      credit_note = UpwoofListings.client.void_credit_note(id: id)
      expect(credit_note).to be_a(CreditNote)
      expect(credit_note['status']).to eq('void')
    end
  end

  # DELETE /credit_notes/{id}
  describe '#delete_credit_note' do
    let(:url) { "#{UpwoofListings.url.chomp('/')}/credit_notes/1?access_token=#{UpwoofListings.api_key}" }

    it 'deletes a never-issued credit note' do
      stub_request(:delete, url).to_return(status: 204)

      expect(UpwoofListings.client.delete_credit_note(id: 1)).to be true
    end

    it 'raises a ClientError when the credit note was already issued' do
      body = { errors: ['The credit note was issued and cannot be deleted'] }.to_json
      stub_request(:delete, url).to_return(status: 403, body: body, headers: { 'Content-Type' => 'application/json' })

      expect { UpwoofListings.client.delete_credit_note(id: 1) }.to raise_error(UpwoofListings::Errors::ClientError)
    end
  end
end
