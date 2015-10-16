defmodule Metrics.MathTest do
  use ExUnit.Case, async: true
  alias Honeybadger.Metrics.Math

  setup do
    requests = [122, 87, 820, 45, 731]
    {:ok, %{requests: requests}}
  end

  test "mean request time", %{requests: requests} do
    assert 361.0 == Math.mean(requests)
    assert 0     == Math.mean([])
  end

  test "median request time", %{requests: requests} do
    assert 122 == Math.median(requests)
    assert 0   == Math.median([])
  end

  test "slowest request", %{requests: requests} do
    assert 820 == Math.slowest(requests)
    assert 0   == Math.slowest([])
  end

  test "fastest request", %{requests: requests} do
    assert 45 == Math.fastest(requests)
    assert 0  == Math.fastest([])
  end

  test "standard deviation of requests", %{requests: requests} do
    assert 340.48 == Math.standard_deviation(requests)
    assert 0      == Math.standard_deviation([])
  end

  test "calculating the percentile of requests", %{requests: requests} do
    assert 104.5 == Math.percentile(requests, 0.40)
    assert 820  == Math.percentile(requests, 0.90)
    assert Math.percentile(requests, 90) == Math.percentile(requests, 0.90)
    assert Math.percentile(requests, 50) == Math.percentile(requests, 0.50)
  end

end
