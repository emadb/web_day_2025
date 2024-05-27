defmodule Distro.HordeSupervisor do
  use Horde.DynamicSupervisor

  def start_link(_) do
    Horde.DynamicSupervisor.start_link(__MODULE__, [strategy: :one_for_one], name: __MODULE__)
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  def members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end

  def start_counter(id) do
    Horde.DynamicSupervisor.start_child(__MODULE__, {Distro.Counter, [id]})
  end
end
