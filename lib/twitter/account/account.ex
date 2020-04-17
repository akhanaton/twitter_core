defmodule Twitter.Core.Account do
  import Ecto.Query
  alias Twitter.Core.{Account.User, Repo}

  def create_user(user_details) do
    Map.from_struct(user_details)
    |> Map.put(:display_name, "@#{user_details.username}")
    |> build_user
    |> Repo.insert()
  end

  def delete_follower(%{followed_id: followed_id, follower_id: follower_id}) do
    query = from("followers", where: [user_id: ^followed_id, follower_id: ^follower_id])
    Repo.delete_all(query)
  end

  def get_user_by_credentials(%{"email" => email, "password" => pass}) do
    user = get_user_by_email(email)

    cond do
      user && Comeonin.Bcrypt.checkpw(pass, user.password_hash) ->
        %{user | display_name: "@#{user.username}"}

      true ->
        :error
    end
  end

  def insert_follower(%{user_id: user_id, follower_id: follower_id}) do
    user = Repo.get(User, user_id)
    follower = Ecto.build_assoc(user, :followers, follower_id: follower_id)

    Repo.insert(follower)
  end

  # Private
  defp get_user_by_email(email), do: Repo.get_by(User, email: email)

  defp build_user(user_details) do
    %User{}
    |> User.changeset(user_details)
  end
end
