# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's play yards and the dogs placed in them (the playgroups board). Any team member of the listing;
  # an id that isn't the listing's raises {UpwoofListings::Errors::ResourceNotFoundError}.
  module DSL::PlayYards
    # GET /listings/{id}/play_yards
    # Board order (sort, name).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::PlayYard>, nil].
    def get_listing_play_yards(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PlayYard.parse(request(:get, "listings/#{listing_id}/play_yards", params, nil))
    end

    # GET /listings/{id}/play_yards/{play_yard_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] play_yard_id A play yard's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PlayYard, nil].
    def get_listing_play_yard(listing_id:, play_yard_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || play_yard_id.blank?

      Resources::PlayYard.parse(request(:get, "listings/#{listing_id}/play_yards/#{play_yard_id}"))
    end

    # POST /listings/{id}/play_yards
    # Raises {UpwoofListings::Errors::ValidationError} (HTTP 422) for a duplicate name, a bad capacity or a
    # minimum weight above the maximum.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params name and capacity (1-500) required; calm_dogs_only, min_weight_lbs, max_weight_lbs,
    #   sort optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PlayYard, nil].
    def create_listing_play_yard(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PlayYard.parse(request(:post, "listings/#{listing_id}/play_yards", params))
    end

    # PATCH /listings/{id}/play_yards/{play_yard_id}
    # Changes only the fields sent.
    # @param [String] listing_id A listing's ID.
    # @param [String] play_yard_id A play yard's ID.
    # @param [Hash] params Play yard attributes.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PlayYard, nil].
    def patch_listing_play_yard(listing_id:, play_yard_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || play_yard_id.blank?

      Resources::PlayYard.parse(request(:patch, "listings/#{listing_id}/play_yards/#{play_yard_id}", params))
    end

    # DELETE /listings/{id}/play_yards/{play_yard_id}
    # Also removes the placements in the yard.
    # @param [String] listing_id A listing's ID.
    # @param [String] play_yard_id A play yard's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_play_yard(listing_id:, play_yard_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || play_yard_id.blank?

      request(:delete, "listings/#{listing_id}/play_yards/#{play_yard_id}").status == 204
    end

    # GET /listings/{id}/playgroup_assignments
    # Placements overlapping a day, earliest first. Each carries the board's warnings for the window
    # (over_capacity, incompatible, isolation, temperament, size, evaluation_failed, evaluation_pending,
    # evaluation_expired).
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) date (YYYY-MM-DD, default today in the listing's zone), from/to ("HH:MM",
    #   both or neither) for one rotation, pet_id, play_yard_id, page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::PlaygroupAssignment>, nil].
    def get_listing_playgroup_assignments(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PlaygroupAssignment.parse(
        request(:get, "listings/#{listing_id}/playgroup_assignments", params, nil)
      )
    end

    # POST /listings/{id}/playgroup_assignments
    # Place a dog. Raises {UpwoofListings::Errors::ResourceNotFoundError} for a stay, pet or yard that isn't the
    # listing's and {UpwoofListings::Errors::ValidationError} (HTTP 422) when the dog is already in a yard then or
    # the times don't fit.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params reservation_id (a checked-in stay), pet_id (one of its pets), play_yard_id, starts_at
    #   and ends_at (ISO 8601, within one listing-local day), all required.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PlaygroupAssignment, nil].
    def create_listing_playgroup_assignment(listing_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::PlaygroupAssignment.parse(request(:post, "listings/#{listing_id}/playgroup_assignments", params))
    end

    # PATCH /listings/{id}/playgroup_assignments/{playgroup_assignment_id}
    # Move a placement to another of the listing's yards.
    # @param [String] listing_id A listing's ID.
    # @param [String] playgroup_assignment_id A placement's ID.
    # @param [String] play_yard_id The yard to move to.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PlaygroupAssignment, nil].
    def patch_listing_playgroup_assignment(listing_id:, playgroup_assignment_id:, play_yard_id:)
      if listing_id.blank? || playgroup_assignment_id.blank? || play_yard_id.blank?
        raise ArgumentError, 'ID cannot be blank'
      end

      Resources::PlaygroupAssignment.parse(
        request(:patch, "listings/#{listing_id}/playgroup_assignments/#{playgroup_assignment_id}",
                { play_yard_id: play_yard_id })
      )
    end

    # DELETE /listings/{id}/playgroup_assignments/{playgroup_assignment_id}
    # @param [String] listing_id A listing's ID.
    # @param [String] playgroup_assignment_id A placement's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_listing_playgroup_assignment(listing_id:, playgroup_assignment_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || playgroup_assignment_id.blank?

      request(:delete, "listings/#{listing_id}/playgroup_assignments/#{playgroup_assignment_id}").status == 204
    end
  end
end
