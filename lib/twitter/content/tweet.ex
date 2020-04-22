defmodule Twitter.Core.Content.Tweet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Core.Content.{Comment, LikedTweet}
  alias Twitter.Core.Account.User

  schema "tweets" do
    field(:content, :string)
    field(:is_visible, :boolean)

    belongs_to(:user, User)
    has_many(:comments, Comment)
    has_many(:liked_tweets, LikedTweet)

    timestamps()
  end

  def changeset(%__MODULE__{} = tweet, attrs \\ %{}) do
    tweet
    |> cast(attrs, [:content, :user_id])
    |> validate_required([:content, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
