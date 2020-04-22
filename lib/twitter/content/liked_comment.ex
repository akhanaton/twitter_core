defmodule Twitter.Core.Content.LikedComment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Twitter.Core.Account.User
  alias Twitter.Core.Content.Comment

  @primary_key false

  schema "liked_comments" do
    belongs_to(:user, User)
    belongs_to(:comment, Comment)

    timestamps()
  end

  def changeset(%__MODULE__{} = liked_comment, attrs \\ %{}) do
    liked_comment
    |> cast(attrs, [:comment_id, :user_id])
    |> validate_required([:comment_id, :user_id])
    |> foreign_key_constraint(:comment_id)
    |> foreign_key_constraint(:user_id)
  end
end
