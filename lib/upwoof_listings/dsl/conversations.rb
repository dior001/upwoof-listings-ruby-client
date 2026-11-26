# frozen_string_literal: true

require 'upwoof_listings/dsl'

module UpwoofListings
  # A listing's conversations (in-app messages, and email replies to them), their messages and a reply. Only
  # conversations with the listing are reachable; any other raises {UpwoofListings::Errors::ResourceNotFoundError}.
  # Any team member may read them; to reply the caller must take part in the conversation. A conversation's id is an
  # inbound_email.received webhook's conversation_id.
  module DSL::Conversations
    # GET /listings/{id}/conversations
    # Most recently active first. Lists leave out the messages; the single conversation includes them.
    # @param [String] listing_id A listing's ID.
    # @param [Hash] params (optional) customer_id (a customer of the listing), updated_since (ISO 8601), page,
    #   per_page.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [Array<UpwoofListings::Resources::Conversation>, nil].
    def get_listing_conversations(listing_id:, params: nil)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank?

      Resources::Conversation.parse(request(:get, "listings/#{listing_id}/conversations", params, nil))
    end

    # GET /listings/{id}/conversations/{thread_id}
    # Every message, oldest first, each with its origin (web, email, automated, ai or api) and sender.
    # @param [String] listing_id A listing's ID.
    # @param [String] conversation_id A conversation's ID.
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::Conversation, nil].
    def get_listing_conversation(listing_id:, conversation_id:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || conversation_id.blank?

      Resources::Conversation.parse(request(:get, "listings/#{listing_id}/conversations/#{conversation_id}"))
    end

    # POST /listings/{id}/conversations/{thread_id}/messages
    # Replies to everyone in the conversation as the caller (origin api); anyone with no UpWoof login is emailed it.
    # Raises {UpwoofListings::Errors::ClientError} (HTTP 403, error not_a_participant) when the caller doesn't take
    # part, {UpwoofListings::Errors::ValidationError} (HTTP 422, message_not_sent) when it can't be posted, and a
    # ClientError (HTTP 429) past 30 replies in 10 minutes with one token.
    # @param [String] listing_id A listing's ID.
    # @param [String] conversation_id A conversation's ID.
    # @param [Hash] params body (required, at most 20,000 characters).
    # @raise [ArgumentError] If the method arguments are blank.
    # @return [UpwoofListings::Resources::ConversationMessage, nil].
    def create_listing_conversation_message(listing_id:, conversation_id:, params:)
      raise ArgumentError, 'ID cannot be blank' if listing_id.blank? || conversation_id.blank?
      raise ArgumentError, 'Params cannot be blank' if params.blank?

      Resources::ConversationMessage.parse(
        request(:post, "listings/#{listing_id}/conversations/#{conversation_id}/messages", params)
      )
    end
  end
end
