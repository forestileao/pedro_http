defmodule Pedro.HttpResponseTest do
  use ExUnit.Case
  alias Pedro.HttpResponse

  @http_response %HttpResponse{
    headers: %{"Content-Type" => "application/json"},
    body: "{\"key\":\"value\"}",
    status: 200
  }

  test "to_string/1 returns a correctly formatted HTTP response" do
    expected_response = """
    HTTP/1.1 200\r
    content-length: 15\r
    content-type: text/html\r
    \r
    {"key":"value"}
    """
    assert HttpResponse.to_string(@http_response) == expected_response
  end
end
