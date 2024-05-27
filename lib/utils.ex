defmodule U do
  def list_server do
    :ets.tab2list(:"keys_Elixir.Distro.CounterRegistry")
  end
end
