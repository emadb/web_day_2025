defmodule U do
  def list_nodes do
    Distro.HordeSupervisor.members()
    |> Enum.map(fn {_, n} -> n end)
  end

  def list_servers do
    Horde.Registry.select(Distro.RoverRegistry, [
      {{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}
    ])
  end

  def start_rovers(n) do
    Enum.map(1..n, fn id ->
      Distro.HordeSupervisor.start_rover(id, {Enum.random(1..100), Enum.random(1..100)})
    end)
  end

  def send(id, cmd) do
    Distro.Rover.send(id, cmd)
  end

  def get_state(id) do
    Distro.Rover.get_state(id)
  end

  def get_pid(id) do
    Horde.Registry.select(Distro.RoverRegistry, [
      {{:"$1", :"$2", :"$3"}, [{:==, :"$1", id}], [{{:"$1", :"$2", :"$3"}}]}
    ])
    |> Enum.at(0)
    |> elem(1)
  end

  def get_node(id) do
    Horde.Registry.select(Distro.RoverRegistry, [
      {{:"$1", :"$2", :"$3"}, [{:==, :"$1", id}], [{{:"$1", :"$2", :"$3"}}]}
    ])
    |> Enum.at(0)
    |> elem(2)
  end
end
