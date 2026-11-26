# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::Conversations do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:conversations_url) { "#{base_url}/listings/1/conversations" }

  it 'lists conversations' do
    stub_request(:get, conversations_url)
      .with(query: { access_token: api_key, customer_id: '4', updated_since: '2026-11-25T00:00:00Z' })
      .to_return(status: 200, headers: json,
                 body: [{ id: 7, subject: 'Room next week?',
                          participants: [{ customer_id: 4, kind: 'customer', name: 'Ana Ruiz' }] }].to_json)

    conversations = client.get_listing_conversations(
      listing_id: 1, params: { customer_id: 4, updated_since: '2026-11-25T00:00:00Z' }
    )
    expect(conversations.first).to be_a(Conversation)
    expect(conversations.first['participants'].first['kind']).to eq('customer')
  end

  it 'gets a conversation with its messages' do
    stub_request(:get, "#{conversations_url}/7?access_token=#{api_key}")
      .to_return(status: 200, headers: json,
                 body: { id: 7, messages: [{ id: 9, body: 'Room for Rex?', origin: 'email' }] }.to_json)

    conversation = client.get_listing_conversation(listing_id: 1, conversation_id: 7)
    expect(conversation['messages'].first['origin']).to eq('email')
  end

  it "raises a ResourceNotFoundError for another listing's conversation" do
    stub_request(:get, "#{conversations_url}/8?access_token=#{api_key}")
      .to_return(status: 404, body: { error: 'not_found' }.to_json, headers: json)

    expect { client.get_listing_conversation(listing_id: 1, conversation_id: 8) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'replies in a conversation' do
    stub_request(:post, "#{conversations_url}/7/messages?access_token=#{api_key}")
      .with(body: { body: 'Yes, from Monday.' }.to_json)
      .to_return(status: 201, headers: json,
                 body: { id: 10, body: 'Yes, from Monday.', origin: 'api', sender_kind: 'team_member' }.to_json)

    message = client.create_listing_conversation_message(listing_id: 1, conversation_id: 7,
                                                         params: { body: 'Yes, from Monday.' })
    expect(message).to be_a(ConversationMessage)
    expect(message['origin']).to eq('api')
  end

  it 'raises a ClientError when the caller does not take part in the conversation' do
    stub_request(:post, "#{conversations_url}/7/messages?access_token=#{api_key}")
      .to_return(status: 403, headers: json, body: { error: 'not_a_participant' }.to_json)

    expect { client.create_listing_conversation_message(listing_id: 1, conversation_id: 7, params: { body: 'Hi' }) }
      .to raise_error(UpwoofListings::Errors::ClientError)
  end

  it 'raises an ArgumentError for blank arguments' do
    expect { client.get_listing_conversations(listing_id: nil) }.to raise_error(ArgumentError)
    expect { client.get_listing_conversation(listing_id: 1, conversation_id: nil) }.to raise_error(ArgumentError)
    expect { client.create_listing_conversation_message(listing_id: 1, conversation_id: 7, params: nil) }
      .to raise_error(ArgumentError)
    expect { client.create_listing_conversation_message(listing_id: nil, conversation_id: 7, params: { body: 'a' }) }
      .to raise_error(ArgumentError)
  end
end
