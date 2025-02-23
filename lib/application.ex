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
      {Horde.Registry, [members: :auto, keys: :unique, name: Distro.RoverRegistry]},
      {Phoenix.PubSub, name: :rover_broker},
      Distro.HordeSupervisor,
      Distro.NodeObserver
    ]

    opts = [strategy: :one_for_one, name: Distro.Supervisor]

    if String.contains?(Atom.to_string(node()), "node_1") do
      Supervisor.start_link(
        [
          {Plug.Cowboy,
           scheme: :http, plug: Distro.Router, options: [port: 4000, dispatch: dispatch()]}
          | children
        ],
        opts
      )
    else
      Supervisor.start_link(children, opts)
    end
  end

  defp dispatch do
    [
      {:_,
       [
         {"/ws", Distro.SocketHandler, []},
         {:_, Plug.Cowboy.Handler, {Distro.Router, []}}
       ]}
    ]
  end
end
