defmodule APISexAuthBearerCacheRiak.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    cleaning_interval = Application.get_env(:apisex_auth_bearer_cache_riak, :cleaning_interval)

    Singleton.start_child(APISexAuthBearerCacheRiak.Cleaner,
                          cleaning_interval,
                          :apisex_auth_bearer_cache_riak_cleaner)
  end
end
