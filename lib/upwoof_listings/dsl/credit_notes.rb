require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::CreditNotes
    # GET /CreditNotes
    # Get credit notes.
    # @param [Hash] params (optional) A hash of query parameters.
    # @return [Array, nil].
    def get_credit_notes(params: nil)
      Resources::CreditNote.parse(request(:get, 'credit_notes/', params, nil))
    end

    # GET /CreditNote/{id}
    # Get a credit note.
    # @param [String] id A credit note's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::CreditNote, nil].
    def get_credit_note(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::CreditNote.parse(request(:get, "credit_notes/#{id}"))
    end

    # POST /credit_notes
    # Create a credit note.
    # @param [Hash] params Credit note attributes.
    # @return [UpwoofListings::Resources::CreditNote, nil].
    def create_credit_note(params:)
      Resources::CreditNote.parse(request(:post, 'credit_notes/', params))
    end

    # PUT /credit_notes/{id}
    # Update a credit note.
    # @param [String] id A credit note's ID.
    # @param [Hash] params Credit note attributes.
    # @return [UpwoofListings::Resources::CreditNote, nil].
    def update_credit_note(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::CreditNote.parse(request(:put, "credit_notes/#{id}", params))
    end

    # PATCH /credit_notes/{id}
    # Partially update a credit note.
    # @param [String] id A credit note's ID.
    # @param [Hash] params Credit note attributes.
    # @return [UpwoofListings::Resources::CreditNote, nil].
    def patch_credit_note(id:, params:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::CreditNote.parse(request(:patch, "credit_notes/#{id}", params))
    end

    # POST /credit_notes/{id}/void
    # Void a credit note.
    # @param [String] id A credit note's ID.
    # @return [UpwoofListings::Resources::CreditNote, nil].
    def void_credit_note(id:)
      raise ArgumentError, 'ID cannot be blank' if id.blank?

      Resources::CreditNote.parse(request(:post, "credit_notes/#{id}/void"))
    end
  end
end
