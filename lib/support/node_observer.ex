defmodule Distro.NodeObserver do
  use GenServer

  require Logger

  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def init(_) do
    :net_kernel.monitor_nodes(true, node_type: :visible)

    {:ok, nil}
  end

  def handle_info({:nodeup, node, _node_type}, state) do
    # set_members(Distro.CounterRegistry)
    set_members(Distro.HordeSupervisor)
    Logger.info("NEW NODE #{inspect(node)}")
    {:noreply, state}
  end

  def handle_info({:nodedown, _node, _node_type}, state) do
    # set_members(Distro.CounterRegistry)
    set_members(Distro.HordeSupervisor)
    {:noreply, state}
  end

  defp set_members(module) do
    members = Enum.map([Node.self() | Node.list()], &{module, &1})
    :ok = Horde.Cluster.set_members(module, members)
  end
end
