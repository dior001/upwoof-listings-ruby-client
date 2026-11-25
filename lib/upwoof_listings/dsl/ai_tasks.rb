# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Emails an address's AI assistant has read and what it recommends doing about them. Any team member of the
  # listing; a caller sees only tasks of the role addresses they receive unless they are an owner/manager. A task
  # the caller can't see raises {UpwoofListings::Errors::ResourceNotFoundError}. Lists leave out body_text and
  # recommendation; the single task and the review methods include them.
  module DSL::AiTasks
    # GET /listings/{id}/ai_tasks
    # Newest first.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) listing_email_address_id, status (queued, awaiting_review, executing,
    #   needs_attention, completed, declined, superseded), page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::AiTask>, nil].
    def get_listing_ai_tasks(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::AiTask.parse(request(:get, "listings/#{listing_id}/ai_tasks", params, nil))
    end

    # GET /listings/{id}/ai_tasks/{task_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] task_id An AI task's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AiTask, nil].
    def get_listing_ai_task(listing_id:, task_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || task_id.blank?

      Resources::AiTask.parse(request(:get, "listings/#{listing_id}/ai_tasks/#{task_id}"))
    end

    # POST /listings/{id}/ai_tasks/{task_id}/approve
    # Runs the recommended action. Raises {UpwoofListings::Errors::ValidationError} (HTTP 422, error unknown_params
    # for a key the action doesn't have, ai_task_refused when the task isn't awaiting review, the params don't
    # validate, the caller's permission group doesn't allow the action, or the action failed).
    # @param [String] listing_id A listing's ID.
    # @param [String] task_id An AI task's ID.
    # @param [Hash] params (optional) params: the recommended action's param names to amended values (e.g.
    #   { params: { message: '...' } }); a key left out keeps the recommended value, nil clears an optional one;
    #   ids for records, arrays of ids, YYYY-MM-DD dates, YYYY-MM-DDTHH:MM listing-local times, text.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AiTask, nil].
    def approve_listing_ai_task(listing_id:, task_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || task_id.blank?

      Resources::AiTask.parse(request(:post, "listings/#{listing_id}/ai_tasks/#{task_id}/approve", params))
    end

    # POST /listings/{id}/ai_tasks/{task_id}/decline
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422, error ai_task_refused) once the task has moved on.
    # @param [String] listing_id A listing's ID.
    # @param [String] task_id An AI task's ID.
    # @param [Hash] params (optional) note (at most 1,000 characters, never sent to the sender).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AiTask, nil].
    def decline_listing_ai_task(listing_id:, task_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || task_id.blank?

      Resources::AiTask.parse(request(:post, "listings/#{listing_id}/ai_tasks/#{task_id}/decline", params))
    end

    # POST /listings/{id}/ai_tasks/{task_id}/handled
    # Marks a task that needs a person (or was interrupted) handled. Raises
    # {UpwoofListings::Errors::ValidationError} (HTTP 422, error ai_task_refused) otherwise.
    # @param [String] listing_id A listing's ID.
    # @param [String] task_id An AI task's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::AiTask, nil].
    def handle_listing_ai_task(listing_id:, task_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || task_id.blank?

      Resources::AiTask.parse(request(:post, "listings/#{listing_id}/ai_tasks/#{task_id}/handled"))
    end
  end
end
