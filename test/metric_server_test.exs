defmodule MetricServerTest do
  use ExUnit.Case
  alias Honeybadger.MetricServer

  setup do
    server = Process.whereis(MetricServer)

    MetricServer.timing(122)
    MetricServer.timing(87)

    {:ok, %{server: server}}
  end

  test "adding request times", %{server: server} do
    assert :sys.get_state(server) == [87, 122]
  end

  test "flushing the metrics", %{server: server} do
    MetricServer.flush
    assert :sys.get_state(server) == []
  end
end
