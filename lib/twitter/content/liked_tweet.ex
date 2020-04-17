defmodule Twitter.Core.Content.LikedTweet do
  use Ecto.Schema

  alias Twitter.Core.Account.User

  schema "liked_tweet" do
    field(:tweet_id, :integer)

    belongs_to(:user, User)

    timestamps()
  end
end
