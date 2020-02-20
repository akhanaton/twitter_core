defmodule Twitter.Core.Timeline do
  alias Twitter.Core.{Timeline, Tweet, User}

  @enforce_keys [:tweets, :user]
  defstruct [:tweets, :user]

  def new(user), do: %Timeline{tweets: %{}, user: user}

  def add(%Timeline{tweets: tweets} = timeline, %Tweet{created: created, id: id}, %User{
        id: user_id
      }) do
    tweet_meta = %{created: created, id: id, user_id: user_id}
    new_tweets = Map.put(tweets, id, tweet_meta)
    %Timeline{timeline | tweets: new_tweets}
  end

  def delete(%Timeline{tweets: tweets} = timeline, %Tweet{id: tweet_id}) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, _} ->
        new_tweets = Map.delete(tweets, tweet_id)

        {:ok, %Timeline{timeline | tweets: new_tweets}}

      :error ->
        {:error, :nonexistent_tweet}
    end
  end
end
