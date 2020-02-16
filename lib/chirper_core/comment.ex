defmodule ChirperCore.Comment do
  alias __MODULE__

  @enforce_keys [:user, :text]

  defstruct [:user, :text]

  def new(user, text), do: {:ok, %Comment{user: user, text: text}}
end
