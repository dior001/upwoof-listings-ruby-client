require 'spec_helper'

describe UpwoofListings::DSL::Users do
  # GET /users
  describe '#get_users' do
    it 'returns an array of users' do
      VCR.use_cassette('get_users') do
        users = UpwoofListings.client.get_users
        expect(users).to be_a(Array)
        expect(users.first).to be_a(User)
      end
    end
  end

  # GET /users/{id}
  describe '#get_user' do
    it 'returns a user' do
      id = VCR.use_cassette('get_users') do
        users = UpwoofListings.client.get_users
        users.first['id']
      end

      VCR.use_cassette('get_user') do
        expect(UpwoofListings.client.get_user(id: id)).to be_a(User)
      end
    end
  end

  # GET /users/me
  describe '#get_users_me' do
    it 'returns the current user' do
      VCR.use_cassette('get_users_me') do
        expect(UpwoofListings.client.get_users_me).to be_a(User)
      end
    end
  end

  # POST /users
  describe '#create_user' do
    it 'creates a user' do
      params = {
        email: "test_#{Time.now.to_i}@example.com",
        first_name: 'Test',
        last_name: 'User',
        password: 'password123',
        password_confirmation: 'password123'
      }
      stub_request(:post, "#{UpwoofListings.url.chomp('/')}/users/?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 201, body: { id: 1, email: params[:email] }.to_json, headers: { 'Content-Type' => 'application/json' })

      user = UpwoofListings.client.create_user(params: params)
      expect(user).to be_a(User)
    end
  end

  # PUT /users/{id}
  describe '#update_user' do
    it 'updates a user' do
      id = 1
      params = { first_name: 'Updated' }
      stub_request(:put, "#{UpwoofListings.url.chomp('/')}/users/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, first_name: 'Updated' }.to_json, headers: { 'Content-Type' => 'application/json' })

      user = UpwoofListings.client.update_user(id: id, params: params)
      expect(user).to be_a(User)
      expect(user['first_name']).to eq('Updated')
    end
  end

  # PATCH /users/{id}
  describe '#patch_user' do
    it 'partially updates a user' do
      id = 1
      params = { last_name: 'Patched' }
      stub_request(:patch, "#{UpwoofListings.url.chomp('/')}/users/#{id}?access_token=#{UpwoofListings.api_key}")
        .with(body: params.to_json)
        .to_return(status: 200, body: { id: id, last_name: 'Patched' }.to_json, headers: { 'Content-Type' => 'application/json' })

      user = UpwoofListings.client.patch_user(id: id, params: params)
      expect(user).to be_a(User)
      expect(user['last_name']).to eq('Patched')
    end
  end

  # DELETE /users/{id}
  describe '#delete_user' do
    it 'deletes a user' do
      id = 1
      stub_request(:delete, "#{UpwoofListings.url.chomp('/')}/users/#{id}?access_token=#{UpwoofListings.api_key}")
        .to_return(status: 204)

      expect(UpwoofListings.client.delete_user(id: id)).to be true
    end
  end
end
