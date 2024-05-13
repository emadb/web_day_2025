defmodule Golex.Counter do
  use GenServer, restart: :transient

  def start_link([id]) do
    GenServer.start_link(__MODULE__, [id], name: via_tuple(id))
  end

  def init([id]) do
    IO.inspect(id, label: "INIT")
    {:ok, %{id: id, count: 0}}
  end

  def get(id) do
    GenServer.call(via_tuple(id), :get)
  end

  def count(id) do
    GenServer.call(via_tuple(id), :count)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set, value}, _from, state) do
    new_state = %{state | count: value}
    {:reply, new_state, new_state}
  end

  def handle_call(:count, _from, state) do
    new_state = %{state | count: state.count + 1}
    {:reply, new_state, new_state}
  end

  defp via_tuple(coord) do
    {:via, Horde.Registry, {Golex.CounterRegistry, coord}}
  end
end
