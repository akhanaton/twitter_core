defmodule Twitter.Core.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  alias Twitter.Core.Account.Follower
  alias Twitter.Core.Content.{LikedComment, LikedTweet, Tweet}

  schema "users" do
    field(:display_name, :string, virtual: true)
    field(:email, :string)
    field(:name, :string)
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    has_many(:tweets, Tweet)
    has_many(:comments, through: [:tweets, :comments])
    has_many(:followers, Follower)
    has_many(:following, Follower, foreign_key: :follower_id)
    has_many(:liked_comments, LikedComment)
    has_many(:liked_tweets, LikedTweet)

    timestamps()
  end

  def changeset(%__MODULE__{} = user, attrs \\ %{}) do
    user
    |> cast(attrs, [:display_name, :email, :name, :username, :password])
    |> validate_required([:email, :name, :username, :password])
    |> validate_format(:email, ~r/@/, message: "is invalid")
    |> validate_length(:password, min: 6, max: 100)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_hashed_password
  end

  defp put_hashed_password(changeset) do
    case changeset.valid? do
      true ->
        changes = changeset.changes
        put_change(changeset, :password_hash, hashpwsalt(changes.password))

      _ ->
        changeset
    end
  end
end
