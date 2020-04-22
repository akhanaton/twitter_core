defmodule Twitter.Core.Comment do
  alias Twitter.Core.User

  @enforce_keys [:is_visible?, :text, :user_id]

  defstruct [:created, :id, :is_visible?, :likes, :text, :tweet_id, :user_id]

  def new(user_id, text),
    do: %__MODULE__{
      is_visible?: true,
      likes: MapSet.new(),
      text: text,
      user_id: user_id
    }

  def toggle_like(%__MODULE__{likes: likes} = comment, %User{id: user_id}) do
    case Enum.find(likes, &(&1 == user_id)) do
      nil ->
        likes = MapSet.put(likes, user_id)
        {:ok, %{comment | likes: likes}}

      _ ->
        likes = MapSet.delete(likes, user_id)
        {:ok, %{comment | likes: likes}}
    end
  end
end
