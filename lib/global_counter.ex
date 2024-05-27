defmodule Distro.GlobalCounter do
  use GenServer, restart: :transient

  def start_link([id]) do
    GenServer.start_link(__MODULE__, [id], name: {:global, id})
  end

  def init([id]) do
    Process.flag(:trap_exit, true)
    IO.inspect({node(), id}, label: "GLOBAL INIT")
    {:ok, %{id: id, count: 0}}
  end

  def get(id) do
    GenServer.call(id, :get)
  end

  def count(id) do
    GenServer.call(id, :count)
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

  def terminate(reason, state) do
    IO.inspect({reason, state}, label: "terminate")
  end
end
