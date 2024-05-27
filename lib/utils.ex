defmodule U do
  def list_servers do
    Horde.Registry.select(Distro.CounterRegistry, [
      {{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}
    ])
  end

  def list_nodes do
    Distro.HordeSupervisor.members()
  end

  def start_counters(n) do
    Enum.map(1..n, fn x -> Distro.HordeSupervisor.start_counter(x) end)
  end

  def count(id) do
    Distro.Counter.count(id)
  end

  def get_state(id) do
    Distro.Counter.get(id)
  end

  def get_pid(id) do
    Horde.Registry.select(Distro.CounterRegistry, [
      {{:"$1", :"$2", :"$3"}, [{:==, :"$1", id}], [{{:"$1", :"$2", :"$3"}}]}
    ])
    |> Enum.at(0)
    |> elem(1)
  end

  def get_node(id) do
    Horde.Registry.select(Distro.CounterRegistry, [
      {{:"$1", :"$2", :"$3"}, [{:==, :"$1", id}], [{{:"$1", :"$2", :"$3"}}]}
    ])
    |> Enum.at(0)
    |> elem(2)
  end
end
