defmodule U do
  def list_nodes do
    Distro.RoverSupervisor.members()
    |> Enum.map(fn {_, n} -> n end)
  end

  def list_rovers do
    ProcessHub.which_children(:my_hub, [:global])
  end

  def start_rovers(n) do
    Enum.map(1..n, fn id ->
      Distro.RoverSupervisor.start_rover(id, {Enum.random(1..100), Enum.random(1..100)})
    end)
  end

  def send(id, cmd) do
    Distro.Rover.send(id, cmd)
  end

  def get_state(id) do
    Distro.Rover.get_state(id)
  end
end
