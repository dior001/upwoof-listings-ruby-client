require 'upwoof_listings/dsl'

module UpwoofListings
  module DSL::CreditNotes
    # GET /CreditNotes
    # Get credit notes.
    # @return [Array, nil].
    def get_credit_notes
      Resources::CreditNote.parse(request(:get, 'credit_notes/', nil, nil))
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
  end
end
