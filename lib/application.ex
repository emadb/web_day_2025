defmodule Distro.Application do
  use Application

  def start(_type, _args) do
    topologies = [
      distro: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: Distro.ClusterSupervisor]]},
      ProcessHub.child_spec(%ProcessHub{
        hub_id: :rover_hub,
        migration_strategy: %ProcessHub.Strategy.Migration.HotSwap{
          retention: 3000,
          handover: true
        }
      }),
      {Phoenix.PubSub, name: :rover_broker}
    ]

    opts = [strategy: :one_for_one, name: Distro.Supervisor]

    if String.contains?(Atom.to_string(node()), "node_1") do
      Supervisor.start_link(
        [
          {Bandit, scheme: :http, plug: Distro.Router, port: 4000}
          | children
        ],
        opts
      )
    else
      Supervisor.start_link(children, opts)
    end
  end
end
