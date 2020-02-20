defmodule Twitter.Core.Comment do
  alias __MODULE__

  @enforce_keys [:created, :id, :text, :user]

  defstruct [:created, :id, :likes, :text, :user]

  def new(id, user, text),
    do: %Comment{
      created: Timex.now(),
      id: id,
      likes: MapSet.new(),
      text: text,
      user: user
    }

  def toggle_like(%Comment{likes: likes} = comment, user) do
    case Enum.find(likes, &(&1 == user)) do
      nil ->
        likes = MapSet.put(likes, user)
        {:ok, %{comment | likes: likes}}

      _ ->
        likes = MapSet.delete(likes, user)
        {:ok, %{comment | likes: likes}}
    end
  end
end
