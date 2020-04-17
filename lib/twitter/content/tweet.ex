defmodule Twitter.Core.Content.Tweet do
  use Ecto.Schema
  alias Twitter.Core.Content.Comment
  alias Twitter.Core.Account.User

  schema "tweets" do
    field(:content, :string)
    field(:is_visible, :boolean)

    belongs_to(:user, User)
    has_many(:comments, Comment)

    timestamps()
  end
end
