defmodule Honeybadger.StatServer do
  use GenServer

  @one_minute 60_000
  @raw_flush {:'$gen_cast', :flush}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## API

  def increment do
    GenServer.cast(__MODULE__, :increment)
  end

  def flush do
    GenServer.cast(__MODULE__, :flush)
  end

  ## GenServer Callbacks

  def init([]) do
    Process.send_after(self, @raw_flush, @one_minute)
    {:ok, 0}
  end

  def handle_cast(:increment, count) do
    {:noreply, count + 1}
  end

  def handle_cast(:flush, count) do
    Process.send_after(self, @raw_flush, @one_minute)
    {:noreply, 0}
  end
end
