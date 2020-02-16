defmodule ChirperCore.Like do
  alias __MODULE__

  @enforce_keys [:user]

  defstruct [:user]

  def new(user), do: {:ok, %Like{user: user}}
end
