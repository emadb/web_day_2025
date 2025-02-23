defmodule Distro.SocketHandler do
  alias Phoenix.PubSub
  @behaviour :cowboy_websocket_handler

  def init(req, state) do
    IO.inspect("SUBSCRIBE")
    PubSub.subscribe(:rover_broker, "crash")
    {:cowboy_websocket, req, state}
  end

  def websocket_init(_state) do
    state = %{}
    {:ok, state}
  end

  def websocket_handle({:text, message}, state) do
    IO.inspect(message, label: "RECEIVED")
    {:reply, {:text, "hello world"}, state}
  end

  def websocket_info(info, state) do
    IO.inspect({info, state}, label: "1>>>")
    {:reply, state}
  end

  # No matter why we terminate, remove all of this pids subscriptions
  def websocket_terminate(_reason, _req, _state) do
    :ok
  end

  def handle_info(msg, socket) do
    IO.inspect({msg, socket}, label: "2>>>")
    {:noreply, socket}
  end
end
