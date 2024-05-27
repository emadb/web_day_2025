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

  def get_id(pid) do
    GenServer.call(pid, :get_id)
  end

  def get(id) do
    GenServer.call({:global, id}, :get)
  end

  def count(id) do
    GenServer.call({:global, id}, :count)
  end

  def node(id) do
    GenServer.call({:global, id}, :node)
  end

  def handle_call(:get_id, _from, state) do
    {:reply, state.id, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:count, _from, state) do
    new_state = %{state | count: state.count + 1}
    {:reply, new_state, new_state}
  end

  def handle_call(:node, _from, state) do
    {:reply, node(), state}
  end

  def terminate(reason, state) do
    IO.inspect({reason, state}, label: "terminate")
  end
end
