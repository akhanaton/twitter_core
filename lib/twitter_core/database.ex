defmodule Twitter.Core.Database do
  alias Twitter.Core.{
    Account,
    Content,
    Comment,
    Tweet,
    User
  }

  alias Twitter.Core.Account.User, as: SchemaUser
  alias Twitter.Core.Content.Tweet, as: SchemaTweet

  def delete_comment(comment_id) do
    case Content.delete_comment(comment_id) do
      {:ok, _comment} -> :ok
      {:error, _changeset} -> :error
    end
  end

  def delete_tweet(%{id: id} = _tweet) do
    case Content.delete_tweet(id) do
      {:ok, _tweet} -> :ok
      {:error, _changeset} -> :error
    end
  end

  def get_all_tweets(%{id: user_id}) do
    case Content.get_all_tweets(user_id) do
      [] ->
        []

      tweets ->
        Enum.map(tweets, &transform_tweet(&1))
    end
  end

  def get_tweet(id) do
    case Content.get_tweet(id) do
      %SchemaTweet{} = tweet -> transform_tweet(tweet)
      nil -> {:error, :tweet_not_found}
    end
  end

  def get_tweet_with_comments(id) do
    case Content.get_tweet_with_comments(id) do
      %SchemaTweet{} = tweet -> transform_tweet(tweet)
      nil -> {:error, :tweet_not_found}
    end
  end

  def get_comment_likes(comment_id) do
    case Content.get_comment_likes(comment_id) do
      [] -> []
      result -> result
    end
  end

  def get_tweet_likes(tweet_id) do
    case Content.get_tweet_likes(tweet_id) do
      [] -> []
      result -> result
    end
  end

  def get_username_by_id(user_id) do
    case Account.get_user_details_by_id(user_id) do
      {:db_error, :invalid_user_id} -> {:db_error, :invalid_user_id}
      user -> user.username
    end
  end

  @spec get_user_by_credentials(map) ::
          {:error, :invalid_user_credentials} | Twitter.Core.User.t()
  def get_user_by_credentials(%{"email" => email, "password" => password} = _user) do
    case Account.get_user_by_credentials(%{email: email, password: password}) do
      %SchemaUser{} = user -> transform_user(user)
      :error -> {:error, :invalid_user_credentials}
    end
  end

  def get_user_details_by_id(user_id) do
    case Account.get_user_details_by_id(user_id) do
      {:db_error, :invalid_user_id} -> {:db_error, :invalid_user_id}
      user -> transform_user(user)
    end
  end

  def like_comment(%{comment_id: _comment_id, user_id: _id} = comment_details) do
    Content.save_liked_comment(comment_details) |> transform_tweet()
  end

  def like_tweet(%{tweet_id: _tweet_id, user_id: _id} = tweet_details) do
    Content.save_liked_tweet(tweet_details)
    |> transform_tweet()
  end

  def save_tweet(tweet) do
    case Content.save_tweet(tweet) do
      {:ok, saved_tweet} ->
        {:ok, transform_tweet(saved_tweet)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def save_comment(%{id: id} = _tweet, %{id: owner_id, text: text}) do
    case Content.save_comment(%{text: text, tweet_id: id, user_id: owner_id}) do
      %SchemaTweet{} = tweet ->
        {:ok, transform_tweet(tweet)}

      _ ->
        :error
    end
  end

  def toggle_follower(%{id: id} = _me, %{followers: followers} = to_follow) do
    case Enum.find(followers, &(&1 == id)) do
      nil -> Account.insert_follower(to_follow.id, id)
      _ -> Account.delete_follower(to_follow.id, id)
    end

    :ok
  end

  defp add_followers(user, followers) do
    %{user | followers: MapSet.new(followers, & &1.follower_id)}
  end

  defp add_following(user, following) do
    %{user | following: MapSet.new(following, & &1.user_id)}
  end

  defp transform_tweet(%SchemaTweet{} = tweet) do
    new_tweet = Tweet.new(tweet.content)

    %{
      new_tweet
      | id: tweet.id,
        created: tweet.inserted_at,
        comments: transform_comments(tweet.comments, %{}),
        likes: transform_likes(tweet.liked_tweets, MapSet.new()),
        is_visible?: tweet.is_visible,
        user_id: tweet.user_id
    }
  end

  def unlike_comment(%{comment_id: _comment_id, user_id: _id} = comment_details) do
    Content.delete_liked_comment(comment_details)
  end

  def unlike_tweet(%{tweet_id: _tweet_id, user_id: _id} = tweet_details) do
    Content.delete_liked_tweet(tweet_details)
  end

  defp add_comment_to_map(comment, comments_map) do
    new_comment = Comment.new(comment.user_id, comment.text)

    new_comment = %{
      new_comment
      | id: comment.id,
        created: comment.inserted_at,
        is_visible?: comment.is_visible,
        tweet_id: comment.tweet_id,
        likes: transform_likes(comment.liked_comments, MapSet.new())
    }

    Map.put(comments_map, comment.id, new_comment)
  end

  defp add_like_to_map_set(like, like_map_set) do
    MapSet.put(like_map_set, like)
  end

  defp transform_comments([], results), do: results

  defp transform_comments([comment | []] = _comments, %{} = results) do
    add_comment_to_map(comment, results)
  end

  defp transform_comments([comment | rest] = _comments, %{} = results) do
    new_results = add_comment_to_map(comment, results)
    transform_comments(rest, new_results)
  end

  defp transform_comments(_, results), do: results

  defp transform_likes([], results), do: results

  defp transform_likes([like | []] = _likes, results) do
    add_like_to_map_set(like.user_id, results)
  end

  defp transform_likes([like | rest] = _likes, results) do
    new_results = add_like_to_map_set(like.user_id, results)
    transform_likes(rest, new_results)
  end

  defp transform_likes(_, results), do: results

  defp transform_user(
         %SchemaUser{
           email: email,
           followers: followers,
           following: following,
           name: name,
           username: username
         } = user
       ) do
    User.new(email, name, username)
    |> Map.put(:id, user.id)
    |> add_followers(followers)
    |> add_following(following)
  end
end
