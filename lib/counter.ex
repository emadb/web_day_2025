defmodule Distro.Counter do
  use GenServer
  require Logger

  def start_link([id]) do
    GenServer.start_link(__MODULE__, [id], name: via_tuple(id))
  end

  def init([id]) do
    Logger.info("Starting counter: #{inspect(id)} on  #{inspect(node())}")
    {:ok, %{id: id, count: 0}}
  end

  def get(id) do
    GenServer.call(via_tuple(id), :get)
  end

  def get_id(pid) do
    GenServer.call(pid, :get_id)
  end

  def count(id) do
    GenServer.call(via_tuple(id), :count)
  end

  def node(id) do
    GenServer.call(via_tuple(id), :node)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_id, _from, state) do
    {:reply, state.id, state}
  end

  def handle_call(:count, _from, state) do
    Logger.info("Counting: #{inspect(state.id)} on  #{inspect(node())}")
    new_state = %{state | count: state.count + 1}
    {:reply, new_state, new_state}
  end

  def handle_call(:node, _from, state) do
    {:reply, node(), state}
  end

  defp via_tuple(id) do
    {:via, Horde.Registry, {Distro.CounterRegistry, id, node()}}
  end
end
