defmodule Pedro.HttpServer.ResponderHelpers do
  def http_response(body) do
    %Pedro.HttpResponse{
      body: body,
    }
  end

  def put_header(%{headers: headers} = resp, key, value) do
    headers = headers |> Map.put(String.downcase(key), value)
    %{resp | headers: headers}
  end

  def put_status(resp, status) do
    %{resp | status: status}
  end
end
