defmodule Twitter.Core.Content.Comment do
  use Ecto.Schema

  alias Twitter.Core.Content.Tweet

  schema "comments" do
    field(:is_visible, :boolean)
    field(:text, :string)

    belongs_to(:tweet, Tweet)

    timestamps()
  end
end
