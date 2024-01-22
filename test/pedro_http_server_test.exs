defmodule PedroHttpServerTest do
  use ExUnit.Case
  doctest PedroHttpServer

  test "greets the world" do
    assert PedroHttpServer.hello() == :world
  end
end
