defmodule Twitter.Core.Content.LikedComment do
  use Ecto.Schema
  alias Twitter.Core.Account.User

  schema "liked_comment" do
    field(:comment_id, :integer)

    belongs_to(:user, User)

    timestamps()
  end
end
