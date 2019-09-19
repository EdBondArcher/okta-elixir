defmodule Okta.Plug.EventHookTest do
  use ExUnit.Case, async: true

  alias Plug.Conn
  alias Okta.Plug.EventHook

  @authorization_token "authorization_token"
  @opts EventHook.init(
          event_handler: EventHookHandlerMock,
          secret_key: @authorization_token
        )

  test "returns 404 with unauthorized requests" do
    conn =
      :post
      |> Plug.Test.conn("/okta/event-hooks")
      |> EventHook.call(@opts)

    assert conn.status == 404
  end

  test "veryfying event hooks" do
    conn =
      :get
      |> build_conn()
      |> Conn.put_req_header("x-okta-verification-challenge", "my verification challenge")
      |> EventHook.call(@opts)

    assert conn.status == 200
    assert conn.resp_body == Jason.encode!(%{verification: "my verification challenge"})

    assert conn
           |> Conn.get_resp_header("content-type")
           |> Enum.at(0)
           |> String.contains?("application/json")

    "application/json; charset=utf-8"
  end

  test "receiving events" do
    Mox.expect(EventHookHandlerMock, :handle_event, fn params ->
      assert params == "some data"
    end)

    conn =
      :post
      |> build_conn()
      |> Map.put(:body_params, "some data")
      |> EventHook.call(@opts)

    assert conn.status == 204
  end

  describe "validating required configs" do
    test "validates event handler" do
      opts = EventHook.init(secret_key: @authorization_token)
      conn = build_conn(:post)

      assert_raise ArgumentError, fn ->
        EventHook.call(conn, opts)
      end
    end

    test "validates secret key" do
      opts = EventHook.init([])
      conn = build_conn(:post)

      assert_raise ArgumentError, fn ->
        EventHook.call(conn, opts)
      end
    end
  end

  defp build_conn(method) do
    method
    |> Plug.Test.conn("/okta/event-hooks")
    |> Conn.put_req_header("authorization", @authorization_token)
  end
end
