defmodule Honeybadger.MetricServer do
  use GenServer

  @one_minute 60_000
  @raw_flush {:'$gen_cast', :flush}

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  ## API

  def timing(time) do
    GenServer.cast(__MODULE__, {:timing, time})
  end

  def flush do
    GenServer.cast(__MODULE__, :flush)
  end

  ## GenServer Callbacks

  def init([]) do
    Process.send_after(self, @raw_flush, @one_minute)
    {:ok, []}
  end

  def handle_cast({:timing, time}, state) do
    {:noreply, [time | state]}
  end

  def handle_cast(:flush, count) do
    Process.send_after(self, @raw_flush, @one_minute)
    {:noreply, []}
  end
end
