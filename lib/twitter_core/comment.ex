defmodule Twitter.Core.Comment do
  alias __MODULE__

  @enforce_keys [:created, :id, :is_visible?, :text, :user_id]

  defstruct [:created, :id, :is_visible?, :likes, :text, :user_id]

  def new(id, user_id, text),
    do: %Comment{
      created: Timex.now(),
      id: id,
      is_visible?: true,
      likes: MapSet.new(),
      text: text,
      user_id: user_id
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
