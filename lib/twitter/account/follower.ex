defmodule Twitter.Core.Account.Follower do
  use Ecto.Schema

  @primary_key false

  schema "followers" do
    field(:user_id, :integer)
    field(:follower_id, :integer)

    timestamps()
  end
end
