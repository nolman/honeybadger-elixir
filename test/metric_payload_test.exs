defmodule MetricPayloadTest do
  use ExUnit.Case, async: true

  setup do
    requests = [122, 87, 820, 45, 731]
    {:ok, %{requests: requests}}
  end

  test "mean request time", %{requests: requests} do
    requests
    |> Enum.sum
    |> div(Enum.count(requests))
    |> IO.inspect
  end

  test "median request time", %{requests: requests}  do
    count = Enum.count(requests)
    case rem(requests, 2) do
      0 ->
        second_pos = div(count, 2) |> round
        first_pos = second - 1
        first = Enum.at(requests, first_pos)
        second = Enum.at(requests, second_pos)
        [first, second]
      1 ->
        position = div(count, 2) |> round
        Enum.at(requests, position)
    end
  end

  test "90th percentile of requests", %{requests: requests}  do
  end

  test "fastest request", %{requests: requests}  do
    Enum.min(requests)
  end

  test "slowest request", %{requests: requests}  do
    Enum.max(requests)
  end

  test "standard deviation of requests", %{requests: requests}  do
    mean = Enum.sum(requests) |> div(Enum.count(requests))
    variance = Enum.reduce(requests, 0.0, fn(num, sum) ->
      sum + (num - mean) * (num - mean)
    end) / Enum.count(requests)
    :math.sqrt(variance)
  end

  test "total number of requests", %{requests: requests}  do
    Enum.count(requests)
  end
end
