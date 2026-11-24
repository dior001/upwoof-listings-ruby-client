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

Every non-2xx response raises an `UpwoofListings::Errors::ClientError` carrying the `response`, its parsed JSON
`body` (nil when there is none) and the API's messages in `errors`: the body's `errors` list (a hash of
messages keyed by field gives its values), else its single `message`, else an empty array. Two subclasses
narrow it:

* `ResourceNotFoundError` (HTTP 404). `redeem_gift_card` answers 404 for any code that isn't a usable gift
  card for the order's listing (unknown, expired, used up or another listing's), the same for each.
* `ValidationError` (HTTP 422): the API refused the request. Changing a reservation's dates through
  `update_reservation`/`patch_reservation` runs the availability check, rebuilds the order and fires
  `reservation.duration_changed`; a date change it refuses raises this, with the reasons in `errors`.

A staff member's token whose permission group doesn't allow the matching page at the listing gets `ClientError`
(HTTP 403, "Your permission group doesn't allow this at this listing"). A collection read without `listing_id`
(reservations, customers, pets, invoices, orders, accommodations, credit notes, pet evaluations, training courses,
store credit) answers 403 when the group denies it at any of the caller's listings; pass a `listing_id` it allows.

A refused custom field answer (`update_customer_custom_fields`/`update_pet_custom_fields`/
`update_reservation_custom_fields`) raises `ValidationError` with `body['unknown_custom_field_ids']` and
`body['errors']` (messages keyed by field definition id); nothing is saved.

```ruby
begin
  client.patch_reservation(id: 42, params: { when_reservation_finish: '2026-12-20' })
rescue UpwoofListings::Errors::ValidationError => e
  puts e.errors
end
```

## Refunding an invoice that was paid in parts (changed in 0.14.0)

An invoice can be paid in parts: cash, a check, a card reader, store credit, or online (`get_invoice_payments`).
**Creating a credit note on a paid invoice that was taken in parts now needs `invoice_payment_id`**, the part the
refund goes back through: a card reader part is refunded to its card, cash or a check is recorded as refunded out
of band, and store credit is credited back to the customer. `create_credit_note` without it raises
`ValidationError` (HTTP 422, "Payment to refund must be chosen: ..."), as does naming more than the part has left to
refund; a part that isn't the invoice's own raises `ResourceNotFoundError`. Code that created credit notes on such
an invoice before 0.14.0 must now pass the part. An invoice paid in one go online is unchanged.

## Pagination

List methods take `page` and `per_page` params. The API returns at most 100 records a page (default 20),
so the client never asks for more: a larger `per_page` is sent as 100 (`UpwoofListings::Client::MAX_PER_PAGE`).

## Resources

Besides the CRUD methods for each core resource (`get_<resources>`, `get_<resource>`, `create_<resource>`,
`update_<resource>`, `patch_<resource>`, `delete_<resource>`), the client wraps:

* Pet evaluations: `get_pet_evaluations`, `get_pet_evaluation`, `create_reservation_pet_evaluation`.
* Pet deactivation: `deactivate_pet` (`passed_away`, `rehomed` or `other`), `reactivate_pet`. Booking an inactive
  pet (`create_reservation`, or `update_reservation` when every pet is inactive) raises `ValidationError`.
  `delete_pet` raises `ValidationError` (`body['error']` `pet_has_history`) for a pet with any stay or listing
  record; deactivate such a pet instead.
* Recurring bookings: `get_recurring_reservation_schedules` (filter by `active`, `customer_id`, `listing_id`),
  `get_recurring_reservation_schedule`, `create_recurring_reservation_schedule` (books the first four weeks of
  dates at once, awaiting review, and emails the customer) and `patch_recurring_reservation_schedule` (`weekdays`,
  `interval`, `pet_ids`, `end_date`; dates no longer booked that still await review, or confirmed themselves and
  haven't started, are cancelled). `weekdays` are `monday` to `sunday`, `interval` 1 to 4 weeks. A schedule set up
  over the API confirms its dates itself when they fit. `deactivate_recurring_reservation_schedule` stops one
  (cancelling its stays still awaiting review, or confirmed themselves and not started, free of charge);
  `skip_recurring_reservation_schedule_date` skips one upcoming date (within 90 days) and
  `restore_recurring_reservation_schedule_date` restores a skipped one. A stopped schedule raises `ValidationError`.
* Physical units (runs and kennels): an accommodation's `units` lists them (`id`, `name`, `sort`, `active`,
  `needs_cleaning`); a reservation's `accommodation_assignments` (`id`, `accommodation_id`, `accommodation_unit`)
  says which unit each booked accommodation is placed in. `update_reservation_unit_assignment` moves an
  assignment to another active unit (or out of its unit, with no `accommodation_unit_id`); a unit another stay
  holds raises `ValidationError`.
* Care plans (any team member, `listing_id` required): `get_pet_feeding_plans`, `get_pet_feeding_plan`,
  `create_pet_feeding_plan`, `patch_pet_feeding_plan`, `delete_pet_feeding_plan`, and the same five for
  `..._pet_medication_plan...` (`frequency` `once_daily`, `twice_daily`, `three_times_daily` or `as_needed`;
  `dose_times` "HH:MM"). They are copied onto each stay at check-in.
* Care log: `get_reservation_care_log_entries` (filter by `date`, `entry_type`, `status`) and
  `complete_care_log_entry` (`outcome` `ate_all`, `ate_some`, `ate_none`, `given` or `refused`; a medication's
  `dose_given` and `administration_notes`, required when refused).
* Credit notes: their amount fields now include any tax Stripe credits back with them (values only; no new
  fields).
* Accommodations: `create_accommodation` and `delete_accommodation` are owner/manager only (a staff member's
  token raises `ClientError`, HTTP 403).
* Store credit: `get_customer_store_credit`, `get_customer_store_credit_transactions`,
  `adjust_customer_store_credit` (owner/manager with two-factor authentication on).
* Pricing rules (owner/manager): `get_listing_pricing_rules`, `get_listing_pricing_rule`,
  `create_listing_pricing_rule`, `patch_listing_pricing_rule`, `delete_listing_pricing_rule`.
* Membership plans (read only): `get_listing_membership_plans`, `get_listing_membership_plan`. A plan's
  `credit_uses` lists what a credit pays for (`stays`, `classes`, `lessons`, `grooming`); `credit_use` and
  `credits_cover_lessons` are deprecated, derived from it. Invoice line items carry `discount` and
  `order_line_item_type` (e.g. `MembershipDiscountOrderLineItem`).
* Custom fields: `get_listing_custom_field_definitions`, `update_customer_custom_fields`,
  `update_pet_custom_fields`, `update_reservation_custom_fields`. Customers, pets and reservations carry their
  answers in `custom_fields`.
* Special opening hours: `get_listing_special_opening_hours`.
* Notification wording (owner/manager): `get_listing_notification_templates`,
  `update_listing_notification_template`, `delete_listing_notification_template`. `notification_key` may be
  `appointment_reminder` (the day-before appointment reminder; email and `any_type` only).
* Training: `get_training_courses`, `get_training_course`, `get_training_course_sessions`,
  `get_training_course_enrollments`, `create_training_course_enrollment`, `get_training_course_waitlist_entries`,
  `get_training_enrollment`, `cancel_training_enrollment`.
* Review page links: `update_listing`/`patch_listing` accept `google_review_url`, `yelp_review_url` and
  `facebook_review_url` (owner/manager), which listings return.
* `get_order` also returns the order a standalone grooming appointment or private lesson is billed on, and any
  order `get_orders` lists that has nothing behind it (such as one made with `create_order`).
* Card readers: `get_listing_card_readers`, `create_listing_card_reader`, `delete_listing_card_reader` (registering
  or removing one needs owner/manager with two-factor authentication on). In-person payments on a reader:
  `create_invoice_terminal_payment`, `get_invoice_terminal_payment`, `cancel_invoice_terminal_payment`, and the
  same three for a shop sale (`create_retail_sale_terminal_payment`, ...). Poll the `get_` method until `status`
  leaves `processing` (`succeeded`, `failed` or `canceled`).
* Online appointment booking, for grooms, private lessons, facility tours and pet transport trips:
  `get_listing_grooming_services`, `get_listing_groomers`, `get_listing_grooming_open_times`,
  `create_listing_grooming_appointments`, `get_listing_grooming_appointments`, and the same five for lessons
  (`get_listing_lesson_services`, `get_listing_trainers`, `get_listing_lesson_open_times`,
  `create_listing_lesson_appointments`, `get_listing_lesson_appointments`), tours (`..._tour_...`,
  `get_listing_tour_hosts`; a tour takes no `pet_ids`) and transport (`..._transport_...`,
  `get_listing_transport_drivers`; a trip takes a pickup and optional drop-off address). A booking that takes a
  deposit comes back `pending_payment` with a `checkout_url` to send the customer to (also for a customer with no
  UpWoof account); pass `success_url`/`cancel_url` (https) for where they return to. Grooms and lessons take
  `pay_with_membership_credits` (one household membership credit an appointment, no deposit). An appointment's
  `status` may be `no_show`; `mark_grooming_appointment_no_show`, `mark_lesson_no_show`, `mark_tour_no_show` and
  `mark_transport_no_show` mark one whose start has passed (a held deposit is kept, owner/manager only; else the
  listing's no-show fee is billed). `reminder_sent_at` says when its day-before reminder went out.
* **Behaviour change (340):** `redeem_gift_card` now holds the card as a payment: the order's `price_cents` and
  `order_line_items` no longer change, and the hold is listed in the order's `gift_card_holds` (`amount_cents`,
  `currency`, `gift_card_id`, `invoice_payment_id`, `settled_at`, `reversed_at`).
* Authorized pickups (any team member, `listing_id` required): `get_customer_authorized_pickups`,
  `get_customer_authorized_pickup`, `create_customer_authorized_pickup`, `patch_customer_authorized_pickup`,
  `delete_customer_authorized_pickup`.
* Customer tags (owner/manager): `get_listing_customer_tags`, `create_listing_customer_tag`,
  `patch_listing_customer_tag`, `delete_listing_customer_tag`, `tag_listing_customer`, `untag_listing_customer`.
  Customers carry `customer_tags`, `get_customers` takes `customer_tag_id`, and pricing rules take
  `customer_tag_ids`.
* Pricing rules also take stay conditions `minimum_nights`, `minimum_pets`, `minimum_weight_lbs`, and
  `stacking_mode` `exclusive_stay_adjustment`.
* Shop products on a stay: `get_listing_stay_products`, `get_reservation_retail_items`,
  `create_reservation_retail_item`, `patch_reservation_retail_item` (changes the `quantity`, 1-99, at the price
  it was added at, while the stay's order is still open; the customer isn't told), `delete_reservation_retail_item`.
  Adding a product already on the stay raises `ValidationError`; change its quantity instead.
* Split payments: `get_invoice_payments` (any team member), `create_invoice_payment` (records part of an open
  invoice taken in `cash` or by `check`; `amount_cents` defaults to everything still owed) and
  `refund_invoice_payment` (refunds one part while the invoice is still open; what is refunded is owed again).
  Recording and refunding need owner/manager with two-factor authentication on. A part's `tender` is
  `card_online`, `card_reader`, `cash`, `check`, `store_credit` or `gift_card` (refunding a gift card part puts the
  value back on the card); `refundable_cents`, `refunded_cents` and `net_amount_cents` say what is left. See "Refunding an invoice that was paid in parts" above.
* Attendance confirmations ("still coming?" requests, read only): `get_reservation_attendance_confirmations`,
  `get_listing_attendance_confirmations` (filter by `date` and `status`: `pending`, `confirmed`, `declined`).
  `visit_on` is the daycare day asked about (nil for the whole stay); `visit_date` is that day or the stay's
  first day.
* A customer's `billing_address`, `email`, `phone_number` and `physical_address`, and an order's
  `order_line_items`, `price_cents` and `uw_fee_amount_cents`, are nil for a staff member whose permission
  group hides customers' contact details or a stay's charges.
* Playgroups: `get_listing_play_yards`, `get_listing_play_yard`, `create_listing_play_yard`,
  `patch_listing_play_yard`, `delete_listing_play_yard`, `get_listing_playgroup_assignments`,
  `create_listing_playgroup_assignment`, `patch_listing_playgroup_assignment` (moves a dog to another yard),
  `delete_listing_playgroup_assignment`. Placements carry the board's `warnings`.
* Report cards for a whole day: `get_listing_report_cards`, `start_listing_report_cards`,
  `publish_listing_report_cards`; a card's photos: `get_report_card_photos`, `share_report_card_photo`,
  `unshare_report_card_photo` (the listing's website photo stream). Report cards carry `reservation_id`.

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

A `store_credit.balance_changed` event (one delivery per store credit ledger movement, `data` the store credit
transaction) joins the reservation, invoice and credit note events a subscription can choose.

## Documentation
https://www.upwoof.com/api-docs/v1

## Contributing

1. Fork it ( https://github.com/dior001/upwoof-listings-ruby-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
