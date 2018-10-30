defmodule APISexAuthBearerCacheRiak do
  @behaviour APISexAuthBearer.Cache

  @moduledoc """
  Implementation of the `APISexAuthBearer.Cache` behaviour with
  Riak as a distributed cache
  """

  @doc """
  `APISexAuthBearer.Cache` callback implementation
  """
  @impl true
  def init_opts(opts) do
    opts
    |> Keyword.put_new(:ttl, 200)
  end

  @doc """
  `APISexAuthBearer.Cache` callback implementation
  """
  @impl true
  def put(bearer, attributes, opts) do
    attributes_b = Riak.CRDT.Register.new(:erlang.term_to_binary(attributes))
    timestamp_i =
      :os.system_time(:seconds)
      |> Integer.to_string()
      |> Riak.CRDT.Register.new()

    bucket_type = Application.get_env(:apisex_auth_bearer_cache_riak, :bucket_type)
    bucket_name = Application.get_env(:apisex_auth_bearer_cache_riak, :bucket_name)

    Riak.CRDT.Map.new()
    |> Riak.CRDT.Map.put("attrs", attributes_b)
    |> Riak.CRDT.Map.put("iat_i", timestamp_i)
    |> Riak.CRDT.Map.put("test_s", Riak.CRDT.Register.new(Enum.random(["pierre", "paul", "jacques"])))
    |> Riak.update(bucket_type, bucket_name, bearer)
  end

  @doc """
  `APISexAuthBearer.Cache` callback implementation
  """
  @impl true
  def get(bearer, opts) do
    bucket_type = Application.get_env(:apisex_auth_bearer_cache_riak, :bucket_type)
    bucket_name = Application.get_env(:apisex_auth_bearer_cache_riak, :bucket_name)

    case Riak.CRDT.Map.value(Riak.find(bucket_type, bucket_name, bearer)) do
      [{{"attrs", :register}, serialized_attrs} | _] = val ->
        IO.inspect(val)
        :erlang.binary_to_term(serialized_attrs)

      _ ->
        nil
    end
  end
end
