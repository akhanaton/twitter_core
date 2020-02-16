defmodule ChirperCore.Chirp do
  alias ChirperCore.{Chirp, Comment, Like}

  @enforce_keys [:content, :title, :owner]

  defstruct [:comments, :content, :likes, :owner, :title]

  def new(content, title, owner),
    do: {:ok, %Chirp{content: content, owner: owner, title: title}}
end
