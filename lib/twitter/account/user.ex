defmodule Twitter.Core.Account.User do
  use Ecto.Schema
  alias Twitter.Core.Content.{LikedComment, LikedTweet, Tweet}
  alias Twitter.Core.Account.Follower

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:username, :string)
    field(:password_hash, :string)

    has_many(:tweets, Tweet)
    has_many(:comments, through: [:tweets, :comments])
    has_many(:followers, Follower)
    has_many(:following, Follower, foreign_key: :follower_id)
    has_many(:liked_comments, LikedComment)
    has_many(:liked_tweets, LikedTweet)

    timestamps()
  end
end
