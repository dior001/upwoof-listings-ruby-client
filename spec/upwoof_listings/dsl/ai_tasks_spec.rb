# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::AiTasks do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:tasks_url) { "#{base_url}/listings/1/ai_tasks" }

  it 'lists AI tasks' do
    stub_request(:get, tasks_url)
      .with(query: { access_token: api_key, status: 'awaiting_review', listing_email_address_id: '2' })
      .to_return(status: 200, headers: json,
                 body: [{ id: 9, status: 'awaiting_review', recommended_action: 'reply',
                          recommended_params: { message: 'Yes, we have room' } }].to_json)

    tasks = client.get_listing_ai_tasks(listing_id: 1,
                                        params: { status: 'awaiting_review', listing_email_address_id: 2 })
    expect(tasks.first).to be_a(AiTask)
    expect(tasks.first['recommended_params']['message']).to eq('Yes, we have room')
  end

  it 'gets an AI task' do
    stub_request(:get, "#{tasks_url}/9?access_token=#{api_key}")
      .to_return(status: 200, headers: json,
                 body: { id: 9, body_text: 'Room for Rex?', recommendation: 'Reply to say yes' }.to_json)

    expect(client.get_listing_ai_task(listing_id: 1, task_id: 9)['body_text']).to eq('Room for Rex?')
  end

  it 'raises a ResourceNotFoundError for a task the caller cannot see' do
    stub_request(:get, "#{tasks_url}/8?access_token=#{api_key}")
      .to_return(status: 404, body: { error: 'not_found' }.to_json, headers: json)

    expect { client.get_listing_ai_task(listing_id: 1, task_id: 8) }
      .to raise_error(UpwoofListings::Errors::ResourceNotFoundError)
  end

  it 'approves an AI task with amended params' do
    body = { params: { message: 'Yes, see you then', pet_ids: [3] } }
    stub_request(:post, "#{tasks_url}/9/approve?access_token=#{api_key}")
      .with(body: body.to_json)
      .to_return(status: 201, headers: json,
                 body: { id: 9, status: 'completed', amended: true, executed_action: 'reply' }.to_json)

    task = client.approve_listing_ai_task(listing_id: 1, task_id: 9, params: body)
    expect(task['status']).to eq('completed')
    expect(task['amended']).to be(true)
  end

  it 'raises a ValidationError when an approval is refused' do
    stub_request(:post, "#{tasks_url}/9/approve?access_token=#{api_key}")
      .to_return(status: 422, headers: json,
                 body: { error: 'ai_task_refused', message: 'No longer waiting for review' }.to_json)

    expect { client.approve_listing_ai_task(listing_id: 1, task_id: 9) }
      .to raise_error(UpwoofListings::Errors::ValidationError)
  end

  it 'declines an AI task' do
    stub_request(:post, "#{tasks_url}/9/decline?access_token=#{api_key}")
      .with(body: { note: 'Already called them' }.to_json)
      .to_return(status: 201, headers: json,
                 body: { id: 9, status: 'declined', decline_note: 'Already called them' }.to_json)

    task = client.decline_listing_ai_task(listing_id: 1, task_id: 9, params: { note: 'Already called them' })
    expect(task['decline_note']).to eq('Already called them')
  end

  it 'marks an AI task handled' do
    stub_request(:post, "#{tasks_url}/9/handled?access_token=#{api_key}")
      .to_return(status: 201, body: { id: 9, status: 'completed', reviewed_by_user_id: 4 }.to_json, headers: json)

    expect(client.handle_listing_ai_task(listing_id: 1, task_id: 9)['reviewed_by_user_id']).to eq(4)
  end

  it "sets an email address's AI assistant" do
    params = { ai_role: 'bookings', ai_review_required: false, ai_automatic_confirmation: true,
               ai_instructions: 'Never book cats' }
    stub_request(:patch, "#{base_url}/listings/1/email_addresses/2?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 200, headers: json,
                 body: { id: 2, ai_role: 'bookings', ai_active: true, ai_review_required: false }.to_json)

    address = client.patch_listing_email_address(listing_id: 1, listing_email_address_id: 2, params: params)
    expect(address['ai_role']).to eq('bookings')
    expect(address['ai_review_required']).to be(false)
  end

  it 'raises an ArgumentError for blank ids' do
    expect { client.get_listing_ai_tasks(listing_id: '') }.to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.get_listing_ai_task(listing_id: 1, task_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.approve_listing_ai_task(listing_id: '', task_id: 9) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.decline_listing_ai_task(listing_id: 1, task_id: '') }
      .to raise_error(ArgumentError, 'ID cannot be blank')
    expect { client.handle_listing_ai_task(listing_id: '', task_id: 9) }
      .to raise_error(ArgumentError, 'ID cannot be blank')
  end
end
