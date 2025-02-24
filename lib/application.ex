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
      {Phoenix.PubSub, name: :rover_broker},
      ProcessHub.child_spec(%ProcessHub{hub_id: :my_hub}),
      Distro.NodeObserver
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
