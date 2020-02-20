defmodule Twitter.Core.Tweet do
  alias Twitter.Core.{Comment, Tweet, User}

  @enforce_keys [:content, :title]

  defstruct [
    :created,
    :comments,
    :content,
    :id,
    :likes,
    :title
  ]

  def add_comment(
        %Tweet{comments: comments} = tweet,
        %User{id: user_id},
        text
      ) do
    id = UUID.uuid1()
    comment = Comment.new(id, user_id, text)
    new_comments = Map.put(comments, id, comment)
    %Tweet{tweet | comments: new_comments}
  end

  def delete_comment(%Tweet{comments: comments} = tweet, %Comment{id: comment_id}) do
    case Map.fetch(tweet.comments, comment_id) do
      {:ok, _} ->
        new_comments = Map.delete(comments, comment_id)
        {:ok, %{tweet | comments: new_comments}}

      :error ->
        {:error, :non_existent_comment}
    end
  end

  def new(content, title) when is_binary(content),
    do: %Tweet{
      created: Timex.now(),
      comments: %{},
      content: content,
      likes: MapSet.new(),
      title: title
    }

  def toggle_like(%Tweet{likes: likes} = tweet, %User{id: user_id}) do
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
        %Tweet{comments: comments} = tweet,
        %Comment{id: comment_id},
        text
      ) do
    case Map.fetch(comments, comment_id) do
      {:ok, comment} ->
        new_comment = %{comment | text: text}
        new_comments = Map.put(comments, comment.id, new_comment)
        {:ok, %{tweet | comments: new_comments}}

      :error ->
        {:error, :non_existent_comment}
    end
  end
end
