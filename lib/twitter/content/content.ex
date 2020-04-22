defmodule Twitter.Core.Content do
  import Ecto.Query
  alias Twitter.Core.Repo
  alias Twitter.Core.Content.{Comment, LikedComment, LikedTweet, Tweet}

  def delete_comment(comment_id) do
    comment = Repo.get(Comment, comment_id)
    comment = Ecto.Changeset.change(comment, is_visible: false)

    case Repo.update(comment) do
      {:ok, comment} -> {:ok, comment}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_tweet(tweet_id) do
    tweet = Repo.get!(Tweet, tweet_id)
    tweet = Ecto.Changeset.change(tweet, is_visible: false)

    case Repo.update(tweet) do
      {:ok, tweet} -> {:ok, tweet}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_liked_comment(%{comment_id: comment_id, user_id: user_id}) do
    query =
      from(l in "liked_comments", where: l.comment_id == ^comment_id, where: l.user_id == ^user_id)

    case Repo.delete_all(query) do
      {count, _} when count == 1 -> :ok
      _ -> {:error, :not_permitted}
    end
  end

  def delete_liked_tweet(%{tweet_id: tweet_id, user_id: user_id}) do
    query =
      from(l in "liked_tweets", where: l.tweet_id == ^tweet_id, where: l.user_id == ^user_id)

    case Repo.delete_all(query) do
      {count, _} when count == 1 -> :ok
      _ -> {:error, :not_permitted}
    end
  end

  def get_all_tweets(user_id) do
    Tweet
    |> where(user_id: ^user_id, is_visible: true)
    |> Repo.all()
  end

  def get_tweet(tweet_id) do
    Tweet
    |> where(is_visible: true, id: ^tweet_id)
    |> Repo.one()
  end

  def get_comment_likes(comment_id) do
    likes =
      LikedComment
      |> where(comment_id: ^comment_id)
      |> Repo.all()

    Enum.map(likes, fn like ->
      %{user_id: like.user_id}
    end)
  end

  def get_tweet_likes(tweet_id) do
    likes =
      LikedTweet
      |> where(tweet_id: ^tweet_id)
      |> Repo.all()

    Enum.map(likes, fn like ->
      %{user_id: like.user_id}
    end)
  end

  def get_tweet_with_comments(tweet_id) do
    get_tweet(tweet_id) |> with_comment_likes() |> with_tweet_likes()
  end

  def save_comment(%{text: text, tweet_id: tweet_id, user_id: user_id}) do
    attrs = %{text: text, tweet_id: tweet_id, user_id: user_id}

    {:ok, comment} =
      %Comment{}
      |> Comment.changeset(attrs)
      |> Repo.insert()

    Tweet |> Repo.get(comment.tweet_id) |> with_comments()
  end

  def save_tweet(%{content: content, user_id: user_id} = _tweet) do
    attrs = %{content: content, user_id: user_id}

    %Tweet{}
    |> Tweet.changeset(attrs)
    |> Repo.insert()
  end

  def save_liked_comment(%{tweet_id: tweet_id, comment_id: _comment_id} = attrs) do
    IO.inspect(attrs.tweet_id)

    %LikedComment{}
    |> LikedComment.changeset(attrs)
    |> Repo.insert()

    get_tweet_with_comments(tweet_id)
  end

  def save_liked_tweet(%{user_id: _user_id, tweet_id: tweet_id} = attrs) do
    %LikedTweet{}
    |> LikedTweet.changeset(attrs)
    |> Repo.insert()

    Tweet |> Repo.get(tweet_id) |> with_tweet_likes()
  end

  defp with_comments(tweet) do
    Repo.preload(tweet, comments: from(c in Comment, where: c.is_visible == true))
  end

  defp with_tweet_likes(tweet) do
    Repo.preload(tweet, [:liked_tweets])
  end

  def with_comment_likes(tweet) do
    query = from(c in Comment, where: c.is_visible == true)
    Repo.preload(tweet, comments: {query, [:liked_comments]})
  end
end
