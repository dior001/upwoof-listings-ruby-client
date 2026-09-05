# UpWoof Listings Ruby Client

A Ruby wrapper for the UpWoof Listings API. Sibling to `upwoof-listings-python-client`, which
wraps the same API for Python callers — the two should stay behaviourally equivalent.

## Stack

Ruby gem. `lib/` the client, `spec/` the tests.

```bash
bundle install
bundle exec rspec
```

## Conventions

A thin wrapper: endpoints to methods, responses parsed. Business logic belongs in the consuming
app. When the API changes, change both this and the Python client — a caller should not be able
to tell which language it is talking from.

Never hit the live API from a spec.
