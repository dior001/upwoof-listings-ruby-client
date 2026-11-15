# UpWoof Listings Ruby Client

A Ruby wrapper for the UpWoof Listings API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'upwoof_listings'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install upwoof_listings

## Errors

Every non-2xx response raises an `UpwoofListings::Errors::ClientError` carrying the `response` and the
API's messages in `errors` (an array, empty when the body has none). Two subclasses narrow it:

* `ResourceNotFoundError` (HTTP 404). `redeem_gift_card` answers 404 for any code that isn't a usable gift
  card for the order's listing (unknown, expired, used up or another listing's), the same for each.
* `ValidationError` (HTTP 422): the API refused the request. Changing a reservation's dates through
  `update_reservation`/`patch_reservation` runs the availability check, rebuilds the order and fires
  `reservation.duration_changed`; a date change it refuses raises this, with the reasons in `errors`.

```ruby
begin
  client.patch_reservation(id: 42, params: { when_reservation_finish: '2026-12-20' })
rescue UpwoofListings::Errors::ValidationError => e
  puts e.errors
end
```

## Pagination

List methods take `page` and `per_page` params. The API returns at most 100 records a page (default 20),
so the client never asks for more: a larger `per_page` is sent as 100 (`UpwoofListings::Client::MAX_PER_PAGE`).

## Verifying webhooks

Each webhook delivery carries `X-Upwoof-Timestamp` (Unix seconds) and `X-Upwoof-Timestamped-Signature`
(`Base64(HMAC-SHA256(secret, "<timestamp>.<body>"))`) alongside the body-only `X-Upwoof-Signature`.
Verify the timestamped one against the raw request body; it also rejects a delivery more than five minutes
old (or ahead), so a captured request can't be replayed:

```ruby
webhooks = UpwoofListings::Webhooks
verified = webhooks.verify_timestamped_signature(
  payload: request.raw_post,
  timestamp: request.headers[webhooks::TIMESTAMP_HEADER],
  signature: request.headers[webhooks::TIMESTAMPED_SIGNATURE_HEADER],
  secret: ENV.fetch('UPWOOF_WEBHOOK_SECRET') # tolerance: 300 by default
)
head :bad_request unless verified
```

`UpwoofListings::Webhooks.verify_signature(payload:, signature:, secret:)` still checks the body-only signature.

## Documentation
https://pethotels.upwoof.com/api-docs/v1

## Contributing

1. Fork it ( https://github.com/dior001/upwoof-listings-ruby-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
