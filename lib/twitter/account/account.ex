defmodule Twitter.Core.Account do
  alias Twitter.Core.{Account.User, Repo}

  def create_user(user_details) do
    Map.from_struct(user_details)
    |> Map.put(:display_name, "@#{user_details.username}")
    |> build_user
    |> Repo.insert()
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

  # Private

  defp get_user_by_email(email), do: Repo.get_by(User, email: email)

  defp build_user(user_details) do
    %User{}
    |> User.changeset(user_details)
  end
end
