defmodule Twitter.Core.Timeline do
  alias Twitter.Core.Tweet

  @enforce_keys [:tweets]
  defstruct [:tweets]

  def new(), do: %__MODULE__{tweets: %{}}

  def add(_timeline, %Tweet{id: tweet_id})
      when tweet_id == nil,
      do: {:error, :invalid_tweet}

  def add(_timeline, %Tweet{user_id: user_id})
      when user_id == nil,
      do: {:error, :invalid_user}

  def add(
        %__MODULE__{tweets: tweets} = timeline,
        %Tweet{id: tweet_id, user_id: user_id}
      ) do
    tweet_meta = %{tweet_id: tweet_id, user_id: user_id}
    new_tweets = Map.put(tweets, tweet_id, tweet_meta)
    %__MODULE__{timeline | tweets: new_tweets}
  end

  def delete(%__MODULE__{tweets: tweets} = timeline, %Tweet{id: tweet_id}) do
    case Map.fetch(tweets, tweet_id) do
      {:ok, _} ->
        new_tweets = Map.delete(tweets, tweet_id)

        {:ok, %__MODULE__{timeline | tweets: new_tweets}}

      :error ->
        {:error, :tweet_not_found}
    end
  end
end
