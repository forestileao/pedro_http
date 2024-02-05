defmodule Pedro.HttpServerTest do
  use ExUnit.Case
  doctest Pedro.HttpServer


  setup_all do
    Finch.start_link(name: Pedro.Finch)
    :ok
  end

  describe "start/2" do
    setup tags do
      responder = tags[:responder]
      old_responder = Application.get_env(:pedro_http_server, :responder)
      Application.put_env(:pedro_http_server, :responder, responder)

      on_exit(fn ->
        Application.put_env(:pedro_http_server, :responder, old_responder)
      end)
    end


    @tag responder: nil
    test "raises when responder not configured" do
      assert_raise(
        RuntimeError,
        fn -> Pedro.HttpServer.start(4041) end)
    end

    @tag responder: Pedro.TestResponder
    test "starts a server when responder is configured" do
      Task.start_link(fn ->
        Pedro.HttpServer.start(4041)
      end)

      {:ok, response} =
        :get
        |> Finch.build("http://localhost:4041/hello")
        |> Finch.request(Pedro.Finch)

      assert response.status == 200
      assert response.body == "Hello, World!"
      assert {"content-type", "text/html"} in response.headers

      {:ok, response} =
        :get
        |> Finch.build("http://localhost:4041/bad")
        |> Finch.request(Pedro.Finch)

      assert response.status == 404
      assert response.body == "Not Found"
      assert {"content-type", "text/html"} in response.headers
    end
  end
end
