defmodule ChirpTest do
  use ExUnit.Case
  alias ChirperCore.Chirp

  test "chirp has title" do
    {:ok, chirp} = Chirp.new("my title", "Hello world!", "todd")
    assert is_binary(chirp.title)
  end
end
