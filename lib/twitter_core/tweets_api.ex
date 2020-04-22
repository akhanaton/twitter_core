defmodule Twitter.Core.TweetsAPI do
  alias Twitter.Core.{
    AccountServer,
    Comment,
    Database,
    ProcessRegistry,
    Tweet,
    User
  }

  def add_comment(%Tweet{} = tweet, %Comment{text: text, user_id: user_id}) do
    case Database.save_comment(tweet, %{id: user_id, text: text}) do
      {:ok, comment} ->
        comment

      :error ->
        :error
    end
  end

  def all_tweets(%User{} = user) do
    Database.get_all_tweets(user)
  end

  def delete_comment(
        %Comment{user_id: commenter_id} = comment,
        %User{id: deleter_id} = _comment_deleter
      ) do
    case commenter_id == deleter_id do
      true ->
        Database.delete_comment(comment.id)

      false ->
        {:error, :not_permitted}
    end
  end

  def delete_tweet(%Tweet{} = tweet, %User{id: id}) do
    case tweet.user_id == id do
      true -> Database.delete_tweet(tweet)
      false -> {:error, :not_permitted}
    end
  end

  def get_tweet(tweet_id) do
    Database.get_tweet_with_comments(tweet_id)
  end

  def toggle_like_comment(
        %Comment{id: comment_id, tweet_id: tweet_id} = _comment,
        %User{id: user_id} = _commenter
      ) do
    comment_likes = Database.get_comment_likes(comment_id)

    case Enum.find_index(comment_likes, fn like -> like.user_id == user_id end) do
      nil ->
        Database.like_comment(%{comment_id: comment_id, user_id: user_id, tweet_id: tweet_id})

      _ ->
        Database.unlike_comment(%{comment_id: comment_id, user_id: user_id})
    end
  end

  def toggle_like_tweet(%Tweet{id: tweet_id} = _tweet, %User{id: user_id} = _liker) do
    tweet_likes = Database.get_tweet_likes(tweet_id)

    case Enum.find_index(tweet_likes, fn like -> like.user_id == user_id end) do
      nil -> Database.like_tweet(%{tweet_id: tweet_id, user_id: user_id})
      _ -> Database.unlike_tweet(%{tweet_id: tweet_id, user_id: user_id})
    end
  end

  def tweet(%Tweet{} = tweet, %User{id: id}) do
    tweet = %{tweet | user_id: id}

    with {:ok, saved_tweet} <- Database.save_tweet(tweet) do
      update_my_timeline(saved_tweet)
      saved_tweet
    else
      {:error, _changeset} -> {:error, :invalid_tweet}
    end
  end

  defp log_owner(user_id) do
    Database.get_username_by_id(user_id)
  end

  defp update_my_timeline(tweet) do
    username = log_owner(tweet.user_id)

    [{my_pid, _}] =
      Registry.lookup(
        ProcessRegistry,
        {AccountServer, username}
      )

    send(my_pid, {:update_my_timeline, tweet})
  end
end
