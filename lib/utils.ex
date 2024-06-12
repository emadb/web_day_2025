defmodule U do
  def list_nodes do
    Distro.HordeSupervisor.members()
    |> Enum.map(fn {_, n} -> n end)
  end

  def list_servers do
    Horde.Registry.select(Distro.CounterRegistry, [
      {{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}
    ])
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

  defp send_random() do
    list_servers()
    |> Enum.shuffle()
    |> Enum.take(3)
    |> Enum.map(fn {id, _, _} -> Distro.Counter.count(id) end)

    Process.sleep(1000)
    send_random()
  end

  def start_task do
    Task.start(fn ->
      send_random()
    end)
  end
end
