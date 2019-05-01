defmodule APIacAuthBearerCacheRiak do
  require Logger

  @behaviour APIacAuthBearer.Cache

  @moduledoc """
  Implementation of the `APIacAuthBearer.Cache` behaviour with
  Riak as a distributed cache
  """

  @doc """
  Installs the index and schema on a bucket

  The installed schema disables idnexing of the bearer attributes for performance reason. The
  following elements are installed:
  - schema (apiac_auth_bearer_cache_riak_schema)
  - index (apiac_auth_bearer_cache_riak_index)

  ## Options
  Either passed directly as a parameter of this function or retrieved from the configuration
  file:
  - `bucket-type`: a `String.t()` for the bucket type (that shall be created beforehand)
  - `bucket-name`: a `String.t()` for the bucket name. Defaults to `"bearer_cache"`
  """

  def install(opts) do
    opts = init_opts(opts)

    :ok =
      Riak.Search.Schema.create(
        schema_name(),
        (:code.priv_dir(:apiac_auth_bearer_cache_riak) ++ '/schema.xml') |> File.read!()
      )

    :ok = Riak.Search.Index.put(index_name(), schema_name())

    :ok = Riak.Search.Index.set({opts[:bucket_type], opts[:bucket_name]}, index_name())
  end

  @doc """
  `APIacAuthBearer.Cache` callback implementation
  """
  @impl true
  def init_opts(opts) do
    opts
    |> Keyword.put_new(:bucket_type, Application.get_env(:apiac_auth_bearer_cache_riak, :bucket_type))
    |> Keyword.put_new(:bucket_name, Application.get_env(:apiac_auth_bearer_cache_riak, :bucket_name, "bearer_cache"))
  end

  @impl true

  def put(bearer, attributes, opts) do
    attributes_register =
      attributes
      |> :erlang.term_to_binary()
      |> Base.encode64(padding: false)
      |> Riak.CRDT.Register.new()

    if attributes["exp"] do
      exp =
        attributes["exp"]
        |> to_string()
        |> Riak.CRDT.Register.new()

      Riak.CRDT.Map.new()
      |> Riak.CRDT.Map.put("exp_int", exp)
      |> Riak.CRDT.Map.put("bearer_attributes_binary", attributes_register)
      |> Riak.update(opts[:bucket_type], opts[:bucket_name], bearer)
    else
      Logger.warn("Inserting bearer with no expiration: #{String.slice(bearer, 1..5)}...")

      Riak.CRDT.Map.new()
      |> Riak.CRDT.Map.put("bearer_attributes_binary", attributes_register)
      |> Riak.update(opts[:bucket_type], opts[:bucket_name], bearer)
    end
  end

  @impl true

  def get(bearer, opts) do
    case Riak.find(opts[:bucket_type], opts[:bucket_name], bearer) do
      res when not is_nil(res) ->
        res
        |> Riak.CRDT.Map.get(:register, "bearer_attributes_binary")
        |> Base.decode64!(padding: false)
        |> :erlang.binary_to_term()

      nil ->
        nil
    end
  end

  @doc false

  def schema_name(), do: "apiac_auth_bearer_cache_riak_schema"

  @doc false

  def index_name(), do: "apiac_auth_bearer_cache_riak_index"
end
