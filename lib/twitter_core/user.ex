defmodule Twitter.Core.User do
  alias __MODULE__

  @moduledoc ~S"""
    Create a `user` with the ability for other users to follow/unfollow
  """

  @enforce_keys [:email, :name, :username]

  defstruct [
    :email,
    :followers,
    :following,
    :id,
    :name,
    :username
  ]

  @doc """
    Create a new user

  ## Examples

      iex> Twitter.Core.User.new("alice@fakemail.fake", "Alice B.", "alice")
      {:ok,
       %Twitter.Core.User{
         email: "alice@fakemail.fake",
         followers: #MapSet<[]>,
         following: #MapSet<[]>,
         id: nil,
         name: "Alice B.",
         username: "alice"
       }}

  """

  def new(email, name, username),
    do:
      {:ok,
       %User{
         email: email,
         followers: MapSet.new(),
         following: MapSet.new(),
         name: name,
         username: username
       }}

  def toggle_follower(%User{followers: followers} = user, %User{id: id}) do
    case Enum.find(followers, &(&1 == id)) do
      nil ->
        new_followers = MapSet.put(followers, id)
        %{user | followers: new_followers}

      _ ->
        new_followers = MapSet.delete(followers, id)
        %{user | followers: new_followers}
    end
  end

  def toggle_following(%User{following: following} = user, %User{id: id}) do
    case Enum.find(following, &(&1 == id)) do
      nil ->
        new_following = MapSet.put(following, id)
        %{user | following: new_following}

      _ ->
        new_following = MapSet.delete(following, id)
        %{user | following: new_following}
    end
  end
end
