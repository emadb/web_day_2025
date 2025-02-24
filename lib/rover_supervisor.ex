defmodule Distro.RoverSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [strategy: :one_for_one], name: __MODULE__)
  end

  def init(init_arg) do
    DynamicSupervisor.init(init_arg)
  end

  def members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end

  def start_rover(id, {x, y}) do
    child_spec = %{
      id: id,
      start: {Distro.Rover, :start_link, [[id, {x, y}]]}
    }

    ProcessHub.start_child(:my_hub, child_spec)
  end
end
