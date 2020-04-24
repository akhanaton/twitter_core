defmodule Twitter.Core.Tweet do
  alias Twitter.Core.{Comment, User}

  @enforce_keys [:content]

  defstruct [
    :created,
    :comments,
    :content,
    :id,
    :is_visible?,
    :likes,
    :user_id,
    :display_name,
    :name
  ]

  def add_comment(
        %__MODULE__{comments: comments} = tweet,
        %User{id: user_id},
        text
      ) do
    case user_id == nil do
      true ->
        {:error, :invalid_user}

      false ->
        id = UUID.uuid1()
        comment = Comment.new(user_id, text)
        new_comments = Map.put(comments, id, comment)
        {:ok, %__MODULE__{tweet | comments: new_comments}}
    end
  end

  def delete_comment(%__MODULE__{comments: comments} = tweet, %Comment{id: comment_id}) do
    case Map.fetch(comments, comment_id) do
      {:ok, comment} ->
        deleted_comment = %{comment | is_visible?: false}
        updated_comments = Map.put(comments, comment_id, deleted_comment)
        {:ok, %{tweet | comments: updated_comments}}

      :error ->
        {:error, :comment_not_found}
    end
  end

  def new(content),
    do: %__MODULE__{
      comments: %{},
      content: content,
      likes: MapSet.new()
    }

  def new(), do: {:error, :no_content}

  def toggle_like(%__MODULE__{likes: likes} = tweet, %User{id: user_id}) do
    case Enum.find(likes, &(&1 == user_id)) do
      nil ->
        likes = MapSet.put(likes, user_id)
        %{tweet | likes: likes}

      _ ->
        likes = MapSet.delete(likes, user_id)
        %{tweet | likes: likes}
    end
  end

  def update_comment(
        %__MODULE__{comments: comments} = tweet,
        %Comment{id: comment_id} = new_comment
      ) do
    case Map.fetch(comments, comment_id) do
      {:ok, comment} ->
        new_comments = Map.put(comments, comment.id, new_comment)
        {:ok, %{tweet | comments: new_comments}}

      :error ->
        {:error, :comment_not_found}
    end
  end
end
