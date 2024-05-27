defmodule Receiver do
  def start do
    receive do
      {:say_hello, value} -> IO.puts("Hello " <> value)
      _ -> IO.puts("Message not supported")
    end
    start()
  end
end
