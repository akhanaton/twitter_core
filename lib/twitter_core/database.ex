defmodule Twitter.Core.Database do
  alias Twitter.Core.{Account, User}

  alias Twitter.Core.Account.User, as: SchemaUser

  # alias Twitter.Core.Content

  def get_username_by_id(user_id) do
    case Account.get_user_details_by_id(user_id) do
      {:db_error, :invalid_user_id} -> {:db_error, :invalid_user_id}
      user -> user.username
    end
  end

  @spec get_user_by_credentials(map) ::
          {:error, :invalid_user_credentials} | Twitter.Core.User.t()
  def get_user_by_credentials(%{"email" => email, "password" => password} = _user) do
    case Account.get_user_by_credentials(%{email: email, password: password}) do
      %SchemaUser{} = user -> transform_user(user)
      :error -> {:error, :invalid_user_credentials}
    end
  end

  def get_user_details_by_id(user_id) do
    case Account.get_user_details_by_id(user_id) do
      {:db_error, :invalid_user_id} -> {:db_error, :invalid_user_id}
      user -> transform_user(user)
    end
  end

  def toggle_follower(%{followers: followers} = user, %{id: id} = _follower) do
    case Enum.find(followers, &(&1 == id)) do
      nil -> Account.insert_follower(user.id, id)
      _ -> Account.delete_follower(user.id, id)
    end

    :ok
  end

  defp add_followers(user, followers) do
    %{user | followers: MapSet.new(followers, & &1.follower_id)}
  end

  defp add_following(user, following) do
    %{user | following: MapSet.new(following, & &1.user_id)}
  end

  defp transform_user(
         %SchemaUser{
           email: email,
           followers: followers,
           following: following,
           name: name,
           username: username
         } = user
       ) do
    User.new(email, name, username)
    |> Map.put(:id, user.id)
    |> add_followers(followers)
    |> add_following(following)
  end
end
