defmodule APIacAuthBearerCacheRiak.MixProject do
  use Mix.Project

  def project do
    [
      app: :apiac_auth_bearer_cache_riak,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {APIacAuthBearerCacheRiak.Application, []}
    ]
  end

  defp deps do
    [
      {:apiac_auth_bearer, github: "tanguilp/apiac_auth_bearer", tag: "0.2.0"},
      {:riak, github: "tanguilp/riak-elixir-client"},
      {:singleton, "~> 1.2.0"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
