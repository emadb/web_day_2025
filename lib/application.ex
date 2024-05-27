defmodule Distro.Application do
  use Application

  @impl true
  def start(_type, _args) do
    topologies = [
      golex: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Distro.ClusterSupervisor]]},
      # {Horde.Registry, [members: :auto, keys: :unique, name: Distro.CounterRegistry]},
      Distro.HordeSupervisor,
      Distro.NodeObserver
    ]

    opts = [strategy: :one_for_one, name: Distro.Supervisor]

    if String.contains?(Atom.to_string(node()), "node_1") do
      Supervisor.start_link(
        [
          {Plug.Cowboy, scheme: :http, plug: Distro.Router, options: [port: 4000]} | children
        ],
        opts
      )
    else
      Supervisor.start_link(children, opts)
    end

    #
  end
end
