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

  get "/api/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "hello"}))
  end

  get "/api/nodes" do
    nodes =
      Distro.HordeSupervisor.members()
      |> Enum.map(fn {_, node} -> node end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(nodes))
  end

  get "/api/nodes/:name" do
    counters =
      Horde.DynamicSupervisor.which_children(Distro.HordeSupervisor)
      |> Enum.map(fn {_, pid, _, _} -> pid end)
      |> Enum.map(fn pid -> Distro.Rover.get_id(pid) end)
      |> Enum.map(fn id -> {id, Distro.Rover.node(id)} end)
      |> Enum.reduce([], fn {id, node}, acc ->
        case Atom.to_string(node) do
          ^name -> [Distro.Rover.get(id) | acc]
          _ -> acc
        end
      end)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(counters))
  end

  post "/api/counter" do
    id = Map.get(conn.body_params, "process_id")
    {:ok, _} = Distro.HordeSupervisor.start_counter(id)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{message: "OK"}))
  end

  post "/api/count" do
    id = Map.get(conn.body_params, "process_id")
    state = Distro.Rover.count(id)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(state))
  end

  post "/api/crash" do
    id = Map.get(conn.body_params, "process_id")
    Distro.Rover.crash(id)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Jason.encode!(%{message: "crashed"}))
  end

  get "/" do
    content = File.read!("priv/static/index.html")

    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, content)
  end
end
