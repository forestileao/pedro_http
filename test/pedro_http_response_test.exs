defmodule Pedro.HttpResponseTest do
  use ExUnit.Case
  alias Pedro.HttpResponse

  @http_response %HttpResponse{
    headers: %{"Content-Type" => "text/html"},
    body: "<h1>Hello World!</h1>",
    status: 200
  }

  test "to_string/1 returns a correctly formatted HTTP response" do
    expected_response = """
    HTTP/1.1 200\r
    content-length: #{byte_size(@http_response.body)}\r
    content-type: text/html\r
    \r
    #{@http_response.body}
    """
    assert HttpResponse.to_string(@http_response) == expected_response
  end
end
