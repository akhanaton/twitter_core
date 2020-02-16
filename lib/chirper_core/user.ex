defmodule ChirperCore.User do
  alias __MODULE__

  @enforce_keys [:email, :first_name, :last_name, :username]

  defstruct [
    :email,
    :first_name,
    :followers,
    :following,
    :last_name,
    :username
  ]

  def new(email, first_name, last_name, username),
    do:
      {:ok,
       %User{
         email: email,
         first_name: first_name,
         last_name: last_name,
         username: username
       }}
end
