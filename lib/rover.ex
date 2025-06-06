defmodule Distro.Rover do
  use GenServer
  use ProcessHub.Strategy.Migration.HotSwap

  def start_link([id, {x, y}, dir]) when dir in [:north, :south, :east, :west] do
    GenServer.start_link(__MODULE__, [id, {x, y}, dir], name: via_tuple(id))
  end

  def start_link([id, {x, y}]) do
    start_link([id, {x, y}, :north])
  end

  def init([id, {x, y}, dir]) do
    {:ok, %{id: id, pos: {x, y}, direction: dir, move_count: 0}, {:continue, :post_init}}
  end

  def get_state(id) do
    GenServer.call(via_tuple(id), :get_state)
  end

  def node(id) do
    GenServer.call(via_tuple(id), :node)
  end

  def send(id, cmd) when is_list(cmd) do
    GenServer.call(via_tuple(id), {:send, cmd})
  end

  def send(id, cmd) do
    GenServer.call(via_tuple(id), {:send, [cmd]})
  end

  def crash(id) do
    GenServer.call(via_tuple(id), :crash)
  end

  def handle_continue(:post_init, state) do
    Process.send_after(self(), :explore, Enum.random(1000..3000))
    {:noreply, state}
  end

  def handle_info(:explore, state) do
    Process.send_after(self(), :explore, Enum.random(1000..3000))

    new_state =
      ["L", "R", "F", "B"]
      |> Enum.random()
      |> then(fn c -> move([c], state) end)

    # crash? = false
    crash? = Enum.random(1..20) == 1

    if crash? do
      {:stop, :crash, new_state}
    else
      {:noreply, new_state}
    end
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:node, _from, state) do
    {:reply, node(), state}
  end

  def handle_call(:get_pid, _from, state) do
    {:reply, self(), state}
  end

  def handle_call({:send, cmd}, _from, state) do
    new_state = move(cmd, state)

    {:reply, :ok, new_state}
  end

  def handle_call(:crash, _from, state) do
    {:crash, :boom, state}
  end

  def terminate(_reason, state) do
    Phoenix.PubSub.broadcast(:rover_broker, "crash", state)
  end

  defp move(cmd, state) do
    new_state =
      Enum.reduce(cmd, state, fn c, acc ->
        acc
        |> Map.merge(apply_command(c, acc))
        |> Map.merge(%{move_count: acc.move_count + 1})
      end)

    new_state
  end

  defp apply_command(cmd, %{pos: {x, y}, direction: direction}) do
    %{
      pos: move(cmd, direction, {x, y}),
      direction: rotate(cmd, direction)
    }
  end

  defp move("F", :north, {x, y}), do: {x, y - 1}
  defp move("F", :south, {x, y}), do: {x, y + 1}
  defp move("F", :east, {x, y}), do: {x + 1, y}
  defp move("F", :west, {x, y}), do: {x - 1, y}

  defp move("B", :north, {x, y}), do: {x, y + 1}
  defp move("B", :south, {x, y}), do: {x, y - 1}
  defp move("B", :east, {x, y}), do: {x - 1, y}
  defp move("B", :west, {x, y}), do: {x + 1, y}
  defp move(cmd, _, {x, y}) when cmd in ["L", "R"], do: {x, y}

  defp rotate("L", :north), do: :west
  defp rotate("L", :west), do: :south
  defp rotate("L", :south), do: :east
  defp rotate("L", :east), do: :north

  defp rotate("R", :north), do: :east
  defp rotate("R", :west), do: :north
  defp rotate("R", :south), do: :west
  defp rotate("R", :east), do: :south
  defp rotate(cmd, dir) when cmd in ["F", "B"], do: dir

  defp via_tuple(id) do
    {:via, :global, id}
  end
end
