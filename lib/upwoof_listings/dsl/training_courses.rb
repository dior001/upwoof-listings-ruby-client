# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Group training courses, their sessions, enrollments and waitlist.
  module DSL::TrainingCourses
    # GET /training_courses
    # The caller's listings' courses, by title (without places_left).
    # @param [Hash] params (optional) active, listing_id, page, per_page.
    # @return [Array<UpwoofListings::Resources::TrainingCourse>, nil].
    def get_training_courses(params: nil)
      Resources::TrainingCourse.parse(request(:get, 'training_courses', params, nil))
    end

    # GET /training_courses/{id}
    # One course, including places_left.
    # @param [String] id A course's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TrainingCourse, nil].
    def get_training_course(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::TrainingCourse.parse(request(:get, "training_courses/#{id}"))
    end

    # GET /training_courses/{id}/sessions
    # Earliest first; +upcoming: true+ lists only sessions that haven't ended.
    # @param [String] training_course_id A course's ID.
    # @param [Hash] params (optional) upcoming, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::TrainingClassSession>, nil].
    def get_training_course_sessions(training_course_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if training_course_id.blank?

      Resources::TrainingClassSession.parse(
        request(:get, "training_courses/#{training_course_id}/sessions", params, nil)
      )
    end

    # GET /training_courses/{id}/enrollments
    # Oldest first.
    # @param [String] training_course_id A course's ID.
    # @param [Hash] params (optional) status (enrolled, completed, cancelled), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::TrainingEnrollment>, nil].
    def get_training_course_enrollments(training_course_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if training_course_id.blank?

      Resources::TrainingEnrollment.parse(
        request(:get, "training_courses/#{training_course_id}/enrollments", params, nil)
      )
    end

    # POST /training_courses/{id}/enrollments
    # Enroll pet_id (an active pet of a customer of the course's listing or its group). Raises ClientError
    # (HTTP 403) for a course off sale, {UpwoofListings::Errors::ResourceNotFoundError} for an unknown course or
    # pet, and {UpwoofListings::Errors::ValidationError} (HTTP 422) when the course is full, the pet is already
    # enrolled, the stay isn't the pet's there, a payment is in progress online, or no training membership
    # credit is left.
    # @param [String] training_course_id A course's ID.
    # @param [Hash] params pet_id required; reservation_id and use_membership_credit optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TrainingEnrollment, nil].
    def create_training_course_enrollment(training_course_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if training_course_id.blank?

      Resources::TrainingEnrollment.parse(request(:post, "training_courses/#{training_course_id}/enrollments", params))
    end

    # GET /training_courses/{id}/waitlist_entries
    # In line order.
    # @param [String] training_course_id A course's ID.
    # @param [Hash] params (optional) status (waiting, offered, enrolled, removed), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::TrainingWaitlistEntry>, nil].
    def get_training_course_waitlist_entries(training_course_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if training_course_id.blank?

      Resources::TrainingWaitlistEntry.parse(
        request(:get, "training_courses/#{training_course_id}/waitlist_entries", params, nil)
      )
    end

    # GET /training_enrollments/{id}
    # @param [String] id An enrollment's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TrainingEnrollment, nil].
    def get_training_enrollment(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::TrainingEnrollment.parse(request(:get, "training_enrollments/#{id}"))
    end

    # POST /training_enrollments/{id}/cancel
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) when the enrollment is already completed or
    # cancelled.
    # @param [String] id An enrollment's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::TrainingEnrollment, nil].
    def cancel_training_enrollment(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::TrainingEnrollment.parse(request(:post, "training_enrollments/#{id}/cancel"))
    end
  end
end
