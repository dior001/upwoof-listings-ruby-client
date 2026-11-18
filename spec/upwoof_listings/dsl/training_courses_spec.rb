# frozen_string_literal: true

require 'spec_helper'

describe UpwoofListings::DSL::TrainingCourses do
  let(:client) { UpwoofListings.client }
  let(:base_url) { UpwoofListings.url.chomp('/') }
  let(:api_key) { UpwoofListings.api_key }
  let(:json) { { 'Content-Type' => 'application/json' } }

  let(:courses_url) { "#{base_url}/training_courses" }

  it 'lists courses' do
    stub_request(:get, courses_url).with(query: { access_token: api_key, active: 'true' })
                                   .to_return(status: 200, body: [{ id: 1, title: 'Puppy basics' }].to_json,
                                              headers: json)

    expect(client.get_training_courses(params: { active: true }).first).to be_a(TrainingCourse)
  end

  it 'gets a course' do
    stub_request(:get, "#{courses_url}/1?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 1, places_left: 3 }.to_json, headers: json)

    expect(client.get_training_course(id: 1)['places_left']).to eq(3)
  end

  it "lists a course's sessions" do
    stub_request(:get, "#{courses_url}/1/sessions?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 4, online: true }].to_json, headers: json)

    expect(client.get_training_course_sessions(training_course_id: 1).first).to be_a(TrainingClassSession)
  end

  it "lists a course's enrollments" do
    stub_request(:get, "#{courses_url}/1/enrollments").with(query: { access_token: api_key, status: 'enrolled' })
                                                      .to_return(status: 200, body: [{ id: 6 }].to_json,
                                                                 headers: json)

    enrollments = client.get_training_course_enrollments(training_course_id: 1, params: { status: 'enrolled' })
    expect(enrollments.first).to be_a(TrainingEnrollment)
  end

  it 'enrolls a pet' do
    params = { pet_id: 3, use_membership_credit: true }
    stub_request(:post, "#{courses_url}/1/enrollments?access_token=#{api_key}")
      .with(body: params.to_json)
      .to_return(status: 201, body: { id: 7, paid_with_membership_credit: true }.to_json, headers: json)

    expect(client.create_training_course_enrollment(training_course_id: 1, params: params)['id']).to eq(7)
  end

  it 'raises a ValidationError when the course is full' do
    stub_request(:post, "#{courses_url}/1/enrollments?access_token=#{api_key}")
      .to_return(status: 422, body: { errors: ['This course is full'] }.to_json)

    expect { client.create_training_course_enrollment(training_course_id: 1, params: { pet_id: 3 }) }
      .to raise_error(UpwoofListings::Errors::ValidationError) { |e| expect(e.errors).to eq(['This course is full']) }
  end

  it "lists a course's waitlist" do
    stub_request(:get, "#{courses_url}/1/waitlist_entries?access_token=#{api_key}")
      .to_return(status: 200, body: [{ id: 8, status: 'offered' }].to_json, headers: json)

    expect(client.get_training_course_waitlist_entries(training_course_id: 1).first).to be_a(TrainingWaitlistEntry)
  end

  it 'gets an enrollment' do
    stub_request(:get, "#{base_url}/training_enrollments/7?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 7 }.to_json, headers: json)

    expect(client.get_training_enrollment(id: 7)).to be_a(TrainingEnrollment)
  end

  it 'cancels an enrollment' do
    stub_request(:post, "#{base_url}/training_enrollments/7/cancel?access_token=#{api_key}")
      .to_return(status: 200, body: { id: 7, status: 'cancelled' }.to_json, headers: json)

    expect(client.cancel_training_enrollment(id: 7)['status']).to eq('cancelled')
  end

  it 'raises an ArgumentError for blank ids' do
    [
      -> { client.get_training_course(id: '') },
      -> { client.get_training_course_sessions(training_course_id: '') },
      -> { client.get_training_course_enrollments(training_course_id: '') },
      -> { client.create_training_course_enrollment(training_course_id: '', params: {}) },
      -> { client.get_training_course_waitlist_entries(training_course_id: '') },
      -> { client.get_training_enrollment(id: '') },
      -> { client.cancel_training_enrollment(id: '') }
    ].each { |call| expect(&call).to raise_error(ArgumentError, 'ID cannot be blank') }
  end
end
