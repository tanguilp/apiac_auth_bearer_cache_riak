# APISexAuthBearerCacheRiak

An application implementing the `APIacAuthBearer.Cache` behaviour with Cachex

## Installation

To use it in your application as your cache for the `APIacAuthBearer` plug, add this to your
dependencies:

```elixir
{:apiac_auth_bearer_cache_riak, github: "tanguilp/apiac_auth_bearer_cache_riak", tag: "0.2.0"}
```

and then reference this cache implementation in your plug options:
```elixir
Plug APIacAuthBearer, bearer_validator: {APIacAuthBearer,[...]},
		       cache: {APIacAuthBearerCacheRiak, [bucket_type: "apiac_auth_bearer_cache_riak_token_cache"]}

```

The options are:
- `bucket-type`: a `String.t()` for the bucket type (that shall be created beforehand).
**Mandatory**
- `bucket-name`: a `String.t()` for the bucket name. Defaults to `"bearer_cache"`

Besides, and when using the cleaning process, you shall call the
`APIacAuthBearerCacheRiak.install/1` function once at startup. This function:
- installs a custom schema
- sets an index using this schema on the target bucket

This schema is needed to:
- index expiration timestamps
- not index bearer binary data

The bucket type shalle be created first with the `map` datatype, for example typing:
```bash
$ sudo riak-admin bucket-type create apiac_auth_bearer_cache_riak_token_cache '{"props":{"datatype":"map", "backend":"memory_mult"}}'
apiac_auth_bearer_cache_riak_token_cache created

$ sudo riak-admin bucket-type activate apiac_auth_bearer_cache_riak_token_cache
apiac_auth_bearer_cache_riak_token_cache has been activated
```

## Configuration

Configuration options are:
- `bucket-type`: a `String.t()` for the bucket type (that shall be created beforehand)
- `bucket-name`: a `String.t()` for the bucket name. Defaults to `"bearer_cache"`
- `cleaning_interval`: an `integer()` to periodically launch the cleaning process. Set to `nil`
if you don't want to trigger the cleaning process. Defaults to `nil`

Note that bucket-related values set up in plugs take precedence over those of configuration
files.

Example:
```elixir
use Mix.Config

config :pooler, pools: [
  [
    name: :riak,
    group: :riak,
    max_count: 10,
    init_count: 5,
    start_mfa: {Riak.Connection, :start_link, ['127.0.0.1', 8087]}
  ]
]

config :apiac_auth_bearer_cache_riak,
  bucket_type: "apiac_auth_bearer_cache_riak_token_cache",
  cleaning_interval: 60
```

The riak cluster shall be configured through the `riak` library.
