defmodule Distro.RoverManager do
  def members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end

  def start_rover(id, {x, y}) do
    child_spec = %{
      id: id,
      start: {Distro.Rover, :start_link, [[id, {x, y}]]}
    }

    ProcessHub.start_child(:rover_hub, child_spec)
  end
end
