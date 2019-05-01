defmodule APIacAuthBearerCacheRiak.Cleaner do
  @moduledoc false

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(interval) do
    if interval != nil do
      Process.send_after(self(), :clean, interval * 1000)
    end

    {:ok, interval}
  end

  def handle_info(:clean, interval) do
    clean_cache()
    Process.send_after(self(), :clean, interval * 1000)
    {:noreply, interval}
  end

  defp clean_cache() do
    Logger.info"#{__MODULE__}: starting cleaning process on #{node()}"

    index_name = APIacAuthBearerCacheRiak.index_name()

    case Riak.Search.query(index_name, "exp_int_register:[0 TO #{:os.system_time(:second)}]") do
      {:ok, {:search_results, result_list, _, _}} ->
        for {_index_name, attribute_list} <- result_list do
          bearer = :proplists.get_value("_yz_rk", attribute_list)

          Logger.info("#{__MODULE__}: removing expired bearer `#{bearer}`")

          opts = APIacAuthBearerCacheRiak.init_opts([])

          Riak.delete({opts[:bucket_type], opts[:bucket_name]}, bearer)
        end

      _ ->
        nil
    end
  end
end
