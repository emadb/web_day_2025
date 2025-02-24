defmodule Distro.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.Static,
    at: "/",
    from: "priv/static"
  )

  plug(:match)
  plug(:dispatch)

  get "/ws" do
    conn
    |> WebSockAdapter.upgrade(Distro.SocketHandler, [], timeout: 60_000)
    |> halt()
  end

  get "/api/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "hello"}))
  end

  get "/api/nodes" do
    nodes =
      Distro.RoverManager.members()
      |> Enum.map(fn {_, node} -> node end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(nodes))
  end

  get "/api/nodes/:name" do
    counters =
      ProcessHub.which_children(:rover_hub, [:global])
      |> Enum.flat_map(fn {node, workers} ->
        if to_string(node) == name, do: workers, else: []
      end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.map(fn id -> project_state(Distro.Rover.get_state(id)) end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(counters))
  end

  post "/api/rover" do
    id = Map.get(conn.body_params, "process_id")
    {:ok, _} = Distro.RoverManager.start_rover(id, random_coords())

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "OK"}))
  end

  post "/api/rover/:id/command" do
    cmd = Map.get(conn.body_params, "cmd")
    state = Distro.Rover.send(String.to_integer(id), cmd)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(state))
  end

  get "/" do
    content = File.read!("priv/static/index.html")

    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, content)
  end

  defp project_state(rover) do
    %{rover | pos: [elem(rover.pos, 0), elem(rover.pos, 1)]}
  end

  defp random_coords(), do: {Enum.random(1..100), Enum.random(1..100)}
end
