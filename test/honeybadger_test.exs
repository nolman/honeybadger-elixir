defmodule HoneybadgerTest do
  use ExUnit.Case
  alias Honeybadger.Notice
  alias HTTPoison, as: HTTP
  require Honeybadger

  setup do
    before = Application.get_env :honeybadger, :api_key

    Application.put_env :honeybadger, :api_key, "at3stk3y"

    on_exit(fn ->
      Application.put_env :honeybadger, :api_key, before
    end)
  end

  test "sending a notice" do
    :meck.expect(HTTP, :post, fn(_url, _data, _headers) -> %HTTP.Response{} end)
    Application.put_env(:honeybadger, :exclude_envs, [])

    defmodule Sample do
      def notify do
        metadata = %{foo: "Bar"}
        Honeybadger.notify(%RuntimeError{}, metadata)
      end
    end

    Sample.notify
    :timer.sleep 250

    url = Application.get_env(:honeybadger, :origin) <> "/v1/notices"
    headers = [{"Accept", "application/json"},
               {"Content-Type", "application/json"},
               {"X-API-Key", "at3stk3y"}]

    payload = %Notice{
      error: %{
        backtrace: [
          %{context: "all", file: "lib/process.ex", method: "info", number: 384},
          %{context: "all", file: "lib/honeybadger.ex", method: "do_notify", number: 133},
          %{context: "all", file: "lib/task/supervised.ex", method: "do_apply", number: 74},
          %{context: "all", file: "proc_lib.erl", method: "init_p_do_apply", number: 240}
				], 
        class: "RuntimeError",
        message: "runtime error",
        tags: []},
      notifier: %{
        name: "Honeybadger Elixir Notifier",
        url: "https://github.com/honeybadger-io/honeybadger-elixir",
        version: "0.3.0"
      },
      request: %{
        context: %{
          foo: "Bar"
        }
      },
      server: %{
        environment_name: :test, 
        hostname: "rb-2",
        project_root: "/Users/rb/code/honeybadger"
      }
    }

    assert :meck.called(HTTP, :post, [url, Poison.encode!(payload), headers])
  after
    Application.put_env(:honeybadger, :exclude_envs, [:dev, :test])
  end

  test "getting and setting the context" do
    assert %{} == Honeybadger.context()

    Honeybadger.context(user_id: 1)
    assert %{user_id: 1} == Honeybadger.context()

    Honeybadger.context(%{user_id: 2})
    assert %{user_id: 2} == Honeybadger.context()
  end

  test "calls at compile time are removed in exclude environments" do
    assert [:dev, :test] == Application.get_env(:honeybadger, :exclude_envs)
    assert :ok == Honeybadger.notify(%RuntimeError{})
  end
end
