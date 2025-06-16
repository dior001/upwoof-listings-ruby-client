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
end
