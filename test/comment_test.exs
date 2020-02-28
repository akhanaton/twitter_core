defmodule CommentTest do
  use ExUnit.Case

  alias Twitter.Core.{Comment, User}

  setup do
    comment = Comment.new(UUID.uuid1(), UUID.uuid1(), "A test comment")

    [comment: comment]
  end

  test "like/unlike a comment", state do
    comment = state[:comment]

    {:ok, user} = User.new("alice@gmail.com", "Alice B", "alice")
    user = %{user | id: comment.user_id}

    {:ok, comment} = Comment.toggle_like(comment, user)
    assert MapSet.member?(comment.likes, user.id) == true

    {:ok, comment} = Comment.toggle_like(comment, user)
    assert MapSet.member?(comment.likes, user.id) == false
  end
end
