defmodule APIacAuthBearerCacheRiak.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    cleaning_interval = Application.get_env(:apiac_auth_bearer_cache_riak, :cleaning_interval, nil)

    Singleton.start_child(APIacAuthBearerCacheRiak.Cleaner,
                          cleaning_interval,
                          :apiac_auth_bearer_cache_riak_cleaner)
  end
end
