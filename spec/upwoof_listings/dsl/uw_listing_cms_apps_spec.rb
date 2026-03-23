require 'spec_helper'

describe UpwoofListings::DSL::UwListingCmsApps do
  # GET /uw_listing_cms_apps
  describe '#get_uw_listing_cms_apps' do
    it 'returns an array of CMS apps' do
      stub_request(:get, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 200, body: [{ id: 1 }].to_json, headers: { 'Content-Type' => 'application/json' })

      apps = UpwoofListings.client.get_uw_listing_cms_apps
      expect(apps).to be_a(Array)
      expect(apps.first).to be_a(UwListingCmsApp)
    end

    it 'passes query parameters' do
      params = { workflow_state: 'operational' }
      stub_request(:get, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/?access_token=#{UpwoofListings.api_key}&workflow_state=operational")
        .to_return(status: 200, body: [].to_json, headers: { 'Content-Type' => 'application/json' })

      UpwoofListings.client.get_uw_listing_cms_apps(params: params)
    end
  end

  # GET /uw_listing_cms_apps/{id}
  describe '#get_uw_listing_cms_app' do
    it 'returns a CMS app' do
      id = 1
      stub_request(:get, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 200, body: { id: id }.to_json, headers: { 'Content-Type' => 'application/json' })

      expect(UpwoofListings.client.get_uw_listing_cms_app(id: id)).to be_a(UwListingCmsApp)
    end
  end

  # POST /uw_listing_cms_apps
  describe '#create_uw_listing_cms_app' do
    it 'creates a CMS app' do
      params = { name: 'My App' }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1 }.merge(params).to_json, headers: { 'Content-Type' => 'application/json' })

      expect(UpwoofListings.client.create_uw_listing_cms_app(params: params)).to be_a(UwListingCmsApp)
    end
  end

  # PUT /uw_listing_cms_apps/{id}
  describe '#update_uw_listing_cms_app' do
    it 'updates a CMS app' do
      id = 1
      params = { name: 'My App' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id }.merge(params).to_json, headers: { 'Content-Type' => 'application/json' })

      expect(UpwoofListings.client.update_uw_listing_cms_app(id: id, params: params)).to be_a(UwListingCmsApp)
    end
  end

  # PATCH /uw_listing_cms_apps/{id}
  describe '#patch_uw_listing_cms_app' do
    it 'partially updates a CMS app' do
      id = 1
      params = { name: 'My App' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id }.merge(params).to_json, headers: { 'Content-Type' => 'application/json' })

      expect(UpwoofListings.client.patch_uw_listing_cms_app(id: id, params: params)).to be_a(UwListingCmsApp)
    end
  end

  # DELETE /uw_listing_cms_apps/{id}
  describe '#delete_uw_listing_cms_app' do
    it 'deletes a CMS app' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/uw_listing_cms_apps/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_uw_listing_cms_app(id: id)).to be true
    end
  end
end
