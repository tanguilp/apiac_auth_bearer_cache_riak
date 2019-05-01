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
