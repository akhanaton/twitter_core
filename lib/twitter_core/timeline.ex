defmodule Twitter.Core.Timeline do
  alias __MODULE__
  alias Twitter.Core.Tweet

  @enforce_keys [:tweets]
  defstruct [:tweets]

  def new(), do: %Timeline{tweets: %{}}

  def add(
        %Timeline{tweets: tweets} = timeline,
        %Tweet{id: tweet_id, user_id: user_id}
      )
      when tweet_id != nil do
    tweet_meta = %{tweet_id: tweet_id, user_id: user_id}
    new_tweets = Map.put(tweets, tweet_id, tweet_meta)
    %Timeline{timeline | tweets: new_tweets}
  end

  def delete(%Timeline{tweets: tweets} = timeline, %Tweet{id: tweet_id}) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, _} ->
        new_tweets = Map.delete(tweets, tweet_id)

        {:ok, %Timeline{timeline | tweets: new_tweets}}

      :error ->
        {:error, :tweet_not_found}
    end
  end
end
