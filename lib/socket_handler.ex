defmodule Distro.SocketHandler do
  alias Phoenix.PubSub
  @behaviour WebSock

  def init(_) do
    PubSub.subscribe(:rover_broker, "crash")
    {:ok, %{}}
  end

  def handle_in(_, state) do
    {:ok, state}
  end

  def handle_info(rover, state) do
    {:push, {:text, JSON.encode!(project_state(rover))}, state}
  end

  defp project_state(rover) do
    %{rover | pos: [elem(rover.pos, 0), elem(rover.pos, 1)]}
  end
end
