defmodule Twitter.Core.Content.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Core.Account.User
  alias Twitter.Core.Content.LikedComment
  alias Twitter.Core.Content.Tweet

  schema "comments" do
    field(:is_visible, :boolean)
    field(:text, :string)

    belongs_to(:tweet, Tweet)
    belongs_to(:user, User)
    has_many(:liked_comments, LikedComment)

    timestamps()
  end

  def changeset(%__MODULE__{} = comment, attrs \\ %{}) do
    comment
    |> cast(attrs, [:text, :tweet_id, :user_id])
    |> validate_required([:text, :tweet_id, :user_id])
    |> foreign_key_constraint(:tweet_id)
    |> foreign_key_constraint(:user_id)
  end
end
