defmodule Distro.MySupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [strategy: :one_for_one], name: __MODULE__)
  end

  def init(init_arg) do
    [members: members()]
    |> Keyword.merge(init_arg)
    |> DynamicSupervisor.init()
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def members() do
    Enum.map([Node.self() | Node.list()], &{__MODULE__, &1})
  end

  def start_cell(id) do
    start_child({Distro.GlobalCounter, [id]})
  end
end
