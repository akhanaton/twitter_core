defmodule Twitter.Core.TweetLog do
  alias Twitter.Core.{Tweet, TweetLog}

  defstruct [:user_id, tweets: %{}]

  def new(user_id, tweet \\ %{}) do
    case Map.has_key?(tweet, :created) do
      false ->
        %TweetLog{user_id: user_id}

      _ ->
        %TweetLog{user_id: user_id}
        |> add_tweet(tweet)
    end
  end

  def add_tweet(
        %TweetLog{tweets: tweets} = tweet_list,
        %Tweet{} = tweet
      ) do
    id = UUID.uuid1()
    tweet = Map.put(tweet, :id, id)
    new_tweets = Map.put(tweets, id, tweet)

    %TweetLog{tweet_list | tweets: new_tweets}
  end

  def update_tweet(
        %TweetLog{tweets: tweets} = tweet_list,
        %Tweet{id: id} = tweet
      ) do
    case Map.fetch(tweets, id) do
      {:ok, _} ->
        tweet = %{tweet | id: id}
        new_tweets = Map.put(tweets, id, tweet)
        {:ok, %{tweet_list | tweets: new_tweets}}

      :error ->
        {:error, :nonexistent_tweet}
    end
  end

  def delete_tweet(%TweetLog{tweets: tweets} = tweet_list, %Tweet{id: tweet_id}) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, _} ->
        new_tweets = Map.delete(tweets, tweet_id)
        {:ok, %{tweet_list | tweets: new_tweets}}

      :error ->
        {:error, :invalid_delete_operation}
    end
  end
end
