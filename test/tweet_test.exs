defmodule TweetTest do
  use ExUnit.Case
  alias Twitter.Core.{Comment, Tweet, User}

  setup do
    tweet = Tweet.new("Hello world!")

    {:ok, user} =
      User.new(
        "jdoe@gmail.com",
        "John Doe",
        "jdoe"
      )

    user = %{user | id: UUID.uuid1()}

    [tweet: tweet, user: user]
  end

  test "create a tweet", state do
    tweet = state[:tweet]
    assert tweet.content =~ "Hello world!"
  end

  test "add comment to Tweet", state do
    tweet = state[:tweet]
    user = state[:user]

    {:ok, tweet} = Tweet.add_comment(tweet, user, "A comment")
    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert Enum.count(tweet.comments) == 1
    assert comment.is_visible? == true
    assert comment.text =~ "A comment"
    assert comment.id != nil
    assert comment.created != nil
  end

  test "delete a comment from a tweet - change visibility", state do
    tweet = state[:tweet]
    user = state[:user]

    {:ok, tweet} = Tweet.add_comment(tweet, user, "A comment")
    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert comment.is_visible? == true

    {:ok, tweet} = Tweet.delete_comment(tweet, comment)
    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert comment.is_visible? == false
  end

  test "like/unlike a tweet", state do
    tweet = state[:tweet]
    user = state[:user]

    tweet = Tweet.toggle_like(tweet, user)
    assert MapSet.member?(tweet.likes, user.id) == true

    tweet = Tweet.toggle_like(tweet, user)
    assert MapSet.member?(tweet.likes, user.id) == false
  end

  # update_comment/2 to be used after like/unlike of comment
  test "update a comment after like/unlike of the comment", state do
    tweet = state[:tweet]
    user = state[:user]

    {:ok, tweet} = Tweet.add_comment(tweet, user, "A comment")
    [{_key, comment}] = Enum.take(tweet.comments, 1)

    {:ok, liked_comment} = Comment.toggle_like(comment, user)
    {:ok, tweet} = Tweet.update_comment(tweet, liked_comment)

    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert MapSet.member?(comment.likes, user.id) == true

    {:ok, unliked_comment} = Comment.toggle_like(comment, user)
    {:ok, tweet} = Tweet.update_comment(tweet, unliked_comment)
    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert MapSet.member?(comment.likes, user.id) == false
  end
end
