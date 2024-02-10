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
      start: {
        Task,
        :start_link,
        [fn -> apply(__MODULE__, :start, init_args) end]
      }
    }
  end

  @spec start(char()) :: :ok
  def start(port) when is_integer(port) do
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

    dispatch(req_socket, method, path)
    listen(listen_socket)
  end

  def dispatch(req_socket, method, path) do
    case dispatcher() do
      {mod, opts} ->
        mod.init(req_socket, method, path, opts)

      mod ->
        mod.init(req_socket, method, path, [])
    end
  end

  defp dispatcher() do
    Application.get_env(:pedro_http_server, :dispatcher)
  end
end
