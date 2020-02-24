defmodule UserTest do
  use ExUnit.Case
  alias Twitter.Core.User

  test "creates a new user" do
    {:ok, user} =
      User.new(
        "akhanaton@gmail.com",
        "Enitan Williams",
        "enitan"
      )

    assert user.name == "Enitan"
  end
end
