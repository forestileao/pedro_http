defmodule Pedro.HttpServer do
  @moduledoc """
  Starts an HTTP Server on the given port.
  It logs all coming requests.
  """

  require Logger

  @listener_options [
    active: false,
    packet: :http_bin,
    reuseaddr: true
  ]

  def child_spec(init_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start, init_args}
    }
  end

  @spec start(char()) :: :ok
  def start(port) when is_integer(port) do
    ensure_configured_responder!()

    case :gen_tcp.listen(port, @listener_options) do
      {:ok, listen_socket} ->
        Logger.info "Started Http server on port #{port}"
        listen(listen_socket)
        :gen_tcp.close(listen_socket)
      {:error, error} ->
        Logger.error "Could not start server: #{inspect(error)}"
    end

    :ok
  end

  defp listen(listen_socket) do
    {:ok, req_socket} = :gen_tcp.accept(listen_socket)
    {:ok, req_packets} = :gen_tcp.recv(req_socket, 0)

    {:http_request, method, {_type, path}, _version} = req_packets

    Logger.info("Received HTTP request #{method} at #{path}")

    respond(req_socket, method, path)
    listen(listen_socket)
  end

  defp respond(req_socket, method, path) do
    %Pedro.HttpResponse{} = resp = responder().resp(req_socket, method, path)
    resp_string = resp |> Pedro.HttpResponse.to_string()

    :gen_tcp.send(req_socket, resp_string)

    Logger.info("Response sent: \n#{resp_string}")
    :gen_tcp.close(req_socket)
  end

  defp responder() do
    Application.get_env(:pedro_http_server, :responder)
  end


  @responder_config_error """
  You must configure a responder for the HTTP server.
  Add the following to your config.exs:
  config :pedro_http_server, responder: YourModule
  """
  defp ensure_configured_responder!() do
    case responder() do
      nil -> raise @responder_config_error
      _ -> :ok
    end
  end
end
