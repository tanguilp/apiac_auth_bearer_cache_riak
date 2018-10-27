defmodule APISexAuthBearerCacheRiak do
  @behaviour APISexAuthBearer.Cache

  @bucket_type "dist_cache"
  @bucket_name "bearers"

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
    |> Keyword.put_new(:bucket_type, @bucket_type)
    |> Keyword.put_new(:bucket_name, @bucket_name)
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

    Riak.CRDT.Map.new()
    |> Riak.CRDT.Map.put("attrs", attributes_b)
    |> Riak.CRDT.Map.put("iat_i", timestamp_i)
    |> Riak.update(opts[:bucket_type], opts[:bucket_name], bearer)
  end

  @doc """
  `APISexAuthBearer.Cache` callback implementation
  """
  @impl true
  def get(bearer, opts) do
    case Riak.CRDT.Map.value(Riak.find(opts[:bucket_type], opts[:bucket_name], bearer)) do
      [{{"attrs", :register}, serialized_attrs} | _] ->
        :erlang.binary_to_term(serialized_attrs)

      _ ->
        nil
    end
  end
end
