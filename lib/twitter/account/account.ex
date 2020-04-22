defmodule Twitter.Core.Account do
  import Ecto.Query
  alias Twitter.Core.{Account.User, Repo}
  alias Twitter.Core.User, as: CoreUser

  def build_user(user_details \\ %{}) do
    %User{}
    |> User.changeset(user_details)
  end

  def create_user(user_details) do
    user_changeset = build_user(user_details)

    case Repo.insert(user_changeset) do
      {:ok, user} -> transform_user(user)
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_follower(followed_id, follower_id) do
    query = from("followers", where: [user_id: ^followed_id, follower_id: ^follower_id])
    Repo.delete_all(query)
  end

  def get_user_details_by_id(user_id) do
    case Repo.get(User, user_id) do
      nil -> {:db_error, :invalid_user_id}
      user -> user |> Repo.preload([:followers, :following])
    end
  end

  def get_user_by_credentials(%{email: email, password: pass}) do
    user = get_user_by_email(email)

    cond do
      user && Comeonin.Bcrypt.checkpw(pass, user.password_hash) ->
        user

      true ->
        :error
    end
  end

  def insert_follower(user_id, follower_id) do
    user = Repo.get(User, user_id)
    follower = Ecto.build_assoc(user, :followers, follower_id: follower_id)

    Repo.insert(follower)
  end

  # Private

  defp get_user_by_email(email) do
    Repo.get_by(User, email: email)
    |> Repo.preload([:followers, :following])
  end

  defp transform_user(user) do
    new_user = CoreUser.new(user.email, user.name, user.username)
    new_user = %{new_user | id: user.id}
    {:ok, new_user}
  end
end
