defmodule Pedro.HttpResponse do
  @moduledoc """
  A struct that represents an HTTP response.
  """

  defstruct [headers: %{}, body: "", status: 200]
  @type t :: %__MODULE__{
    headers: map(),
    body: String.t(),
    status: non_neg_integer()
  }
  @http_version 1.1
  @default_content_type "text/plain"

  def to_string(%__MODULE__{
    headers: headers,
    body: body,
    status: status
  }) do
    headers_string = build_headers_string(headers, @default_content_type, byte_size(body))

    """
    HTTP/#{@http_version} #{status}\r
    #{headers_string}\r
    \r
    #{body}
    """
  end

  defp build_headers_string(headers, content_type, byte_size) do
    headers
    |> format_headers()
    |> add_default_headers(content_type, byte_size)
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
    |> Enum.join("\r\n")
  end

  defp format_headers(headers) do
    headers
    |> Enum.map(fn {key, value} -> {String.downcase(key), value} end)
    |> Enum.into(%{})
  end

  defp add_default_headers(headers, content_type, byte_size) do
    headers
    |> Map.put_new("content-type", content_type)
    |> Map.put_new("content-length", byte_size)
  end
end
