require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::VaccinationRecords
    # GET /pets/{pet_id}/vaccination_records
    # List a pet's vaccination records.
    # @param [String] pet_id A pet's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::VaccinationRecord>, nil].
    def get_pet_vaccination_records(pet_id:)
      raise ArgumentError, 'ID cannot be blank' if pet_id.blank?

      Resources::VaccinationRecord.parse(request(:get, "pets/#{pet_id}/vaccination_records", nil, nil))
    end

    # POST /pets/{pet_id}/vaccination_records
    # Create a vaccination record for a pet.
    # @param [String] pet_id A pet's ID.
    # @param [Hash] params Vaccination record attributes (vaccine_name, administered_on, expires_on, notes).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::VaccinationRecord, nil].
    def create_pet_vaccination_record(pet_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if pet_id.blank?

      Resources::VaccinationRecord.parse(request(:post, "pets/#{pet_id}/vaccination_records", params))
    end
  end
end
