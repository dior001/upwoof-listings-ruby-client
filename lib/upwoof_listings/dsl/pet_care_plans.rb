# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A pet's standing care plan: its meals (feeding plans) and medications (medication plans), copied onto each stay at
  # check-in. Every method needs listing_id, one of the caller's team listings (any tier); the pet must be a pet of
  # that listing's (or its group's) customers and the plan one the listing's group keeps, else
  # {UpwoofListings::Errors::ResourceNotFoundError}. Times are wall-clock "HH:MM" in the listing's time zone; a badly
  # formatted time raises {UpwoofListings::Errors::ClientError} (HTTP 400), and a refused plan
  # {UpwoofListings::Errors::ValidationError} (HTTP 422).
  module DSL::PetCarePlans
    # GET /pets/{pet_id}/feeding_plans
    # By time_of_day (untimed last), then id.
    # @param [String] pet_id A pet's ID.
    # @param [String] listing_id One of the caller's listings.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::PetFeedingPlan>, nil].
    def get_pet_feeding_plans(pet_id:, listing_id:, params: nil)
      Resources::PetFeedingPlan.parse(
        request(:get, pet_plan_path(pet_id, 'feeding_plans'), with_listing(listing_id, params), nil)
      )
    end

    # GET /pets/{pet_id}/feeding_plans/{plan_id}
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A feeding plan's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetFeedingPlan, nil].
    def get_pet_feeding_plan(pet_id:, plan_id:, listing_id:)
      Resources::PetFeedingPlan.parse(
        request(:get, pet_plan_path(pet_id, 'feeding_plans', plan_id), with_listing(listing_id), nil)
      )
    end

    # POST /pets/{pet_id}/feeding_plans
    # @param [String] pet_id A pet's ID.
    # @param [Hash] params listing_id and meal_label required; time_of_day ("HH:MM", blank for untimed), quantity,
    #   food_description and special_feeding optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetFeedingPlan, nil].
    def create_pet_feeding_plan(pet_id:, params:)
      Resources::PetFeedingPlan.parse(request(:post, pet_plan_path(pet_id, 'feeding_plans'), params))
    end

    # PATCH /pets/{pet_id}/feeding_plans/{plan_id}
    # Changes only the fields sent (a blank time_of_day makes it untimed).
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A feeding plan's ID.
    # @param [Hash] params listing_id required; meal_label, time_of_day, quantity, food_description, special_feeding.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetFeedingPlan, nil].
    def patch_pet_feeding_plan(pet_id:, plan_id:, params:)
      Resources::PetFeedingPlan.parse(request(:patch, pet_plan_path(pet_id, 'feeding_plans', plan_id), params))
    end

    # DELETE /pets/{pet_id}/feeding_plans/{plan_id}
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A feeding plan's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_pet_feeding_plan(pet_id:, plan_id:, listing_id:)
      request(:delete, pet_plan_path(pet_id, 'feeding_plans', plan_id), with_listing(listing_id)).status == 204
    end

    # GET /pets/{pet_id}/medication_plans
    # By medication_name. effective_dose_times are the times doses fall due (the plan's own dose_times, else the
    # frequency's usual times; empty when as_needed).
    # @param [String] pet_id A pet's ID.
    # @param [String] listing_id One of the caller's listings.
    # @param [Hash] params (optional) page, per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::PetMedicationPlan>, nil].
    def get_pet_medication_plans(pet_id:, listing_id:, params: nil)
      Resources::PetMedicationPlan.parse(
        request(:get, pet_plan_path(pet_id, 'medication_plans'), with_listing(listing_id, params), nil)
      )
    end

    # GET /pets/{pet_id}/medication_plans/{plan_id}
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A medication plan's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetMedicationPlan, nil].
    def get_pet_medication_plan(pet_id:, plan_id:, listing_id:)
      Resources::PetMedicationPlan.parse(
        request(:get, pet_plan_path(pet_id, 'medication_plans', plan_id), with_listing(listing_id), nil)
      )
    end

    # POST /pets/{pet_id}/medication_plans
    # Dose times it can't read raise {UpwoofListings::Errors::ValidationError} (HTTP 422).
    # @param [String] pet_id A pet's ID.
    # @param [Hash] params listing_id and medication_name required; dosage, frequency (once_daily, twice_daily,
    #   three_times_daily, as_needed), dose_times (an array of "HH:MM"; empty for the frequency's usual times) and
    #   instructions optional.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetMedicationPlan, nil].
    def create_pet_medication_plan(pet_id:, params:)
      Resources::PetMedicationPlan.parse(request(:post, pet_plan_path(pet_id, 'medication_plans'), params))
    end

    # PATCH /pets/{pet_id}/medication_plans/{plan_id}
    # Changes only the fields sent.
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A medication plan's ID.
    # @param [Hash] params listing_id required; medication_name, dosage, frequency, dose_times, instructions.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::PetMedicationPlan, nil].
    def patch_pet_medication_plan(pet_id:, plan_id:, params:)
      Resources::PetMedicationPlan.parse(request(:patch, pet_plan_path(pet_id, 'medication_plans', plan_id), params))
    end

    # DELETE /pets/{pet_id}/medication_plans/{plan_id}
    # @param [String] pet_id A pet's ID.
    # @param [String] plan_id A medication plan's ID.
    # @param [String] listing_id One of the caller's listings.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Boolean].
    def delete_pet_medication_plan(pet_id:, plan_id:, listing_id:)
      request(:delete, pet_plan_path(pet_id, 'medication_plans', plan_id), with_listing(listing_id)).status == 204
    end

    private

    def pet_plan_path(pet_id, kind, plan_id = :none)
      raise ArgumentError, 'ID cannot be blank' if pet_id.blank? || (plan_id != :none && plan_id.blank?)

      plan_id == :none ? "pets/#{pet_id}/#{kind}" : "pets/#{pet_id}/#{kind}/#{plan_id}"
    end

    def with_listing(listing_id, params = nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      (params || {}).merge(listing_id: listing_id)
    end
  end
end
