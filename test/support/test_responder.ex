defmodule Pedro.TestResponder do
  import Pedro.HttpServer.ResponderHelpers
  @behaviour Pedro.HttpServer.Responder

  @impl true
  def resp(_req, method, path) do
    cond do
      method == :GET && path == "/hello" ->
        "Hello, World!"
        |> http_response()
        |> put_header("Content-Type", "text/html")
        |> put_status(200)
      true ->
        "Not Found"
        |> http_response()
        |> put_header("Content-Type", "text/html")
        |> put_status(404)
    end
  end
end
