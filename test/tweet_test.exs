defmodule TweetTest do
  use ExUnit.Case
  alias Twitter.Core.Tweet

  test "Tweet has title" do
    {:ok, tweet} = Tweet.new("my title", "Hello world!", "todd")
    assert is_binary(tweet.title())
  end

  test "add comment to Tweet" do
    {:ok, tweet} = Tweet.new("my title", "Hello world!", "todd")
    {:ok, tweet} = Tweet.add_comment(tweet, "My comment", "will")
    {:ok, comment} = Map.fetch(tweet.comments(), "will")
    assert comment.text == "My comment"
  end
end
