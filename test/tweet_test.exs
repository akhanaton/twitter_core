defmodule TweetTest do
  use ExUnit.Case, async: true

  @subject Twitter.Core.Tweet
  alias Twitter.Core.{Comment, User}

  setup do
    tweet = @subject.new("Hello world!")

    user =
      User.new(
        "jdoe@gmail.com",
        "John Doe",
        "jdoe"
      )

    user = %{user | id: UUID.uuid1()}

    [tweet: tweet, user: user]
  end

  describe "new/1" do
    test "create a tweet when passed a message" do
      expected_content = "Hello world!"

      actual_tweet = @subject.new("Hello world!")

      assert actual_tweet.content == expected_content
    end

    test "returns an error when no content is passed in" do
      expected = {:error, :no_content}
      actual = @subject.new()

      assert ^expected = actual
    end
  end

  describe "add_comment/2" do
    test "add comment if user has user id", state do
      tweet = state[:tweet]
      user = state[:user]

      {:ok, tweet} = @subject.add_comment(tweet, user, "A comment")
      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert Enum.count(tweet.comments) == 1
      assert comment.is_visible? == true
      assert comment.text =~ "A comment"
      assert comment.id != nil
      assert comment.created != nil
    end

    test "returns an error if user has no id or id is nil", state do
      tweet = state[:tweet]

      user =
        User.new(
          "jdoe@gmail.com",
          "John Doe",
          "jdoe"
        )

      result = @subject.add_comment(tweet, user, "A comment")
      assert result == {:error, :invalid_user}
    end
  end

  describe "delete/2" do
    test "deleted comment is_visible should be false", state do
      tweet = state[:tweet]
      user = state[:user]

      {:ok, tweet} = @subject.add_comment(tweet, user, "A comment")
      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert comment.is_visible? == true

      {:ok, tweet} = @subject.delete_comment(tweet, comment)
      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert comment.is_visible? == false
    end

    test "you get an error if you try and delete a comment that does not exist", state do
      tweet = state[:tweet]

      comment = Comment.new("123456", "54321", "Hello")
      result = @subject.delete_comment(tweet, comment)
      assert ^result = {:error, :comment_not_found}
    end
  end

  describe "toggle_like/2" do
    test "add user id to tweet.likes if it's not already there", state do
      tweet = state[:tweet]
      user = state[:user]

      tweet = @subject.toggle_like(tweet, user)
      assert MapSet.member?(tweet.likes, user.id) == true
    end

    test "remove user id from tweet.likes if its already there", state do
      tweet = state[:tweet]
      user = state[:user]

      tweet = @subject.toggle_like(tweet, user)
      assert MapSet.member?(tweet.likes, user.id) == true

      tweet = @subject.toggle_like(tweet, user)
      assert MapSet.member?(tweet.likes, user.id) == false
    end
  end

  describe "update_comment/2" do
    test "updates the likes a comment has in a tweet", state do
      tweet = state[:tweet]
      user = state[:user]

      {:ok, tweet} = @subject.add_comment(tweet, user, "A comment")
      [{_key, comment}] = Enum.take(tweet.comments, 1)

      {:ok, liked_comment} = Comment.toggle_like(comment, user)
      {:ok, tweet} = @subject.update_comment(tweet, liked_comment)

      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert MapSet.member?(comment.likes, user.id) == true

      {:ok, unliked_comment} = Comment.toggle_like(comment, user)
      {:ok, tweet} = @subject.update_comment(tweet, unliked_comment)
      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert MapSet.member?(comment.likes, user.id) == false
    end

    # @tag :pending
    test "returns an error if a comment has no id",
         state do
      tweet = state[:tweet]
      user = state[:user]

      {:ok, tweet} = @subject.add_comment(tweet, user, "A comment")

      comment = Comment.new("123456", "54321", "Hello")
      {:ok, liked_comment} = Comment.toggle_like(comment, user)
      result = @subject.update_comment(tweet, liked_comment)

      assert ^result = {:error, :comment_not_found}
    end
  end
end
