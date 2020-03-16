defmodule CommentTest do
  use ExUnit.Case, async: true

  @subject Twitter.Core.Comment

  setup do
    comment = @subject.new(UUID.uuid1(), UUID.uuid1(), "A test comment")

    [comment: comment]
  end

  describe "toggle_like/2" do
    test "like/unlike a comment", state do
      comment = state[:comment]

      {:ok, user} = Twitter.Core.User.new("alice@gmail.com", "Alice B", "alice")
      user = %{user | id: comment.user_id}

      {:ok, comment} = @subject.toggle_like(comment, user)
      assert MapSet.member?(comment.likes, user.id) == true

      {:ok, comment} = @subject.toggle_like(comment, user)
      assert MapSet.member?(comment.likes, user.id) == false
    end
  end
end
