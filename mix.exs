defmodule APISexAuthBearerCacheRiak.MixProject do
  use Mix.Project

  def project do
    [
      app: :apisex_auth_bearer_cache_riak,
      version: "0.1.0",
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
      mod: {APISexAuthBearerCacheRiak.Application, []}
    ]
  end

  defp deps do
    [
      {:apisex_auth_bearer, github: "tanguilp/apisex_auth_bearer", tag: "master"},
      {:riak, "~> 1.1.6"},
      {:singleton, "~> 1.2.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
