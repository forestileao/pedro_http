defmodule Pedro.HttpServer.Responder do
  @type method :: :GET | :POST | :PUT | :PATCH | :DELETE
  @callback resp(term(), method(), String.t()) :: Pedro.HttpResponse.t()
end
