defmodule Twitter.Core.TweetLog do
  alias __MODULE__
  alias Twitter.Core.{Tweet, User}

  defstruct [:user_id, tweets: %{}]

  def add_tweet(
        %TweetLog{tweets: tweets, user_id: user_id} = tweet_list,
        %Tweet{} = tweet
      ) do
    id = UUID.uuid1()
    tweet = %{tweet | id: id, user_id: user_id}
    new_tweets = Map.put(tweets, id, tweet)

    {:ok, %TweetLog{tweet_list | tweets: new_tweets}}
  end

  def all_tweets(%TweetLog{tweets: tweets}) do
    Stream.map(tweets, fn {_tweet_id, tweet} ->
      tweet
    end)
    |> Enum.reject(&(&1.is_visible? == false))
  end

  def delete_tweet(%TweetLog{tweets: tweets} = tweet_list, %Tweet{id: tweet_id}) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, tweet} ->
        deleted_tweet = %{tweet | is_visible?: false}
        updated_tweets = Map.put(tweets, tweet_id, deleted_tweet)
        {:ok, %TweetLog{tweet_list | tweets: updated_tweets}}

      :error ->
        {:error, :invalid_delete_operation}
    end
  end

  def get_last(%TweetLog{tweets: tweets}) do
    [head | _tail] =
      Enum.sort(tweets, fn {_key1, tweet1}, {_key2, tweet2} ->
        case Date.compare(tweet1.created, tweet2.created) do
          :lt ->
            true

          _ ->
            false
        end
      end)

    {_key, tweet} = head
    tweet
  end

  def get_tweet(%TweetLog{tweets: tweets}, tweet_id) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, tweet} ->
        scrubbed_tweet = scrub_deleted_tweet(tweet)
        {:ok, scrubbed_tweet}

      :error ->
        {:error, :tweet_not_found}
    end
  end

  def new(%User{id: user_id}, tweet \\ %{}) when user_id != nil do
    case Map.has_key?(tweet, :created) do
      false ->
        %TweetLog{user_id: user_id}

      _ ->
        %TweetLog{user_id: user_id}
        |> add_tweet(tweet)
    end
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
        {:error, :tweet_not_found}
    end
  end

  defp scrub_deleted_tweet(%Tweet{is_visible?: is_visible} = tweet) do
    case is_visible do
      true -> tweet
      false -> %{tweet | content: "", likes: MapSet.new(), title: ""}
    end
  end
end
