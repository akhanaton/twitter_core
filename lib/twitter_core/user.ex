defmodule Twitter.Core.User do
  alias __MODULE__

  @enforce_keys [:email, :first_name, :id, :last_name, :username]

  defstruct [
    :email,
    :first_name,
    :followers,
    :following,
    :id,
    :last_name,
    :username
  ]

  def new(email, first_name, last_name, username),
    do:
      {:ok,
       %User{
         email: email,
         first_name: first_name,
         followers: MapSet.new(),
         following: MapSet.new(),
         id: UUID.uuid1(),
         last_name: last_name,
         username: username
       }}
end
