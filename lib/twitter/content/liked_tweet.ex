defmodule Twitter.Core.Content.LikedTweet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Core.Account.User
  alias Twitter.Core.Content.Tweet

  @primary_key false

  schema "liked_tweets" do
    belongs_to(:user, User)
    belongs_to(:tweet, Tweet)

    timestamps()
  end

  def changeset(%__MODULE__{} = liked_tweet, attrs \\ %{}) do
    liked_tweet
    |> cast(attrs, [:tweet_id, :user_id])
    |> validate_required([:tweet_id, :user_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:tweet_id)
  end
end
