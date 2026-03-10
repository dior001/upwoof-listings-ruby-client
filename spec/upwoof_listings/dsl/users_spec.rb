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
        expect(UpwoofListings.client.get_user(id:)).to be_a(User)
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
      VCR.use_cassette('create_user_success') do
        user = UpwoofListings.client.create_user(params:)
        expect(user).to be_a(User)
      end
    end
  end
end
