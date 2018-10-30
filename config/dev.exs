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

config :apisex_auth_bearer_cache_riak, bucket_type: "dist_cache",
                                       bucket_name: "bearers",
                                       index_name: "expirable_token",
                                       cleaning_interval: 60 * 10
