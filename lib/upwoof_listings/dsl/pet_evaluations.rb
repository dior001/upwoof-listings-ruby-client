# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # Temperament evaluations and meet-and-greets.
  module DSL::PetEvaluations
    # GET /pet_evaluations
    # List the evaluations recorded at the caller's listings, newest first (evaluated_on desc, id desc).
    # @param [Hash] params (optional) evaluation_type (temperament, meet_and_greet), listing_id, pet_id,
    #   reservation_id, result (pending, passed, partial, failed), page, per_page.
    # @return [Array<UpwoofListings::Resources::PetEvaluation>, nil].
    def get_pet_evaluations(params: nil)
      Resources::PetEvaluation.parse(request(:get, 'pet_evaluations', params, nil))
    end

    # GET /pet_evaluations/{id}
    # Get one evaluation. Raises {UpwoofListings::Errors::ResourceNotFoundError} unless it was recorded at one
    # of the caller's listings.
    # @param [String] id An evaluation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetEvaluation, nil].
    def get_pet_evaluation(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::PetEvaluation.parse(request(:get, "pet_evaluations/#{id}"))
    end

    # POST /reservations/{reservation_id}/pet_evaluations
    # Record an evaluation result for one of a reservation's pets. A pending evaluation the pet already has on
    # that stay is filled in and returned (same id). Raises ResourceNotFoundError for a reservation not at the
    # caller's listings or a pet not on it, and ValidationError (HTTP 422) for an expires_on before evaluated_on.
    # @param [String] reservation_id A reservation's ID.
    # @param [Hash] params pet_id and result (pending, passed, partial, failed) required; evaluation_type
    #   (temperament, meet_and_greet; defaults to the stay's evaluation-visit type, else temperament),
    #   evaluated_on (defaults to today in the listing's time zone), expires_on and notes optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetEvaluation, nil].
    def create_reservation_pet_evaluation(reservation_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if reservation_id.blank?

      Resources::PetEvaluation.parse(request(:post, "reservations/#{reservation_id}/pet_evaluations", params))
    end
  end
end
