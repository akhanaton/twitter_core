defmodule TweetLogTest do
  use ExUnit.Case

  alias Twitter.Core.{Tweet, TweetLog, User}

  setup do
    {:ok, user} = User.new("alice@gmail.com", "Alice B.", "alice")
    user = %{user | id: UUID.uuid1()}
    tweet_list = TweetLog.new(user)

    [tweet_list: tweet_list, user: user]
  end

  test "add a tweet", state do
    tweet_list = state[:tweet_list]
    user = state[:user]
    tweet = Tweet.new("Hello world!")

    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet)

    assert tweet_list.user_id == user.id
    assert Enum.count(tweet_list.tweets) == 1

    [{_key, tweet}] = Enum.take(tweet_list.tweets, 1)
    assert tweet.is_visible? == true
    assert tweet.user_id == user.id
    assert tweet.content =~ "Hello world!"
  end

  test "get all  tweets", state do
    tweet_list = state[:tweet_list]

    tweet1 = Tweet.new("My first tweet")
    tweet2 = Tweet.new("My second tweet")
    tweet3 = Tweet.new("My third tweet")

    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet1)
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet2)
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet3)

    assert Enum.count(tweet_list.tweets) == 3

    tweets = TweetLog.all_tweets(tweet_list)

    assert Enum.count(tweets) == 3
  end

  test "deleted tweet has no content", state do
    tweet_list = state[:tweet_list]

    tweet1 = Tweet.new("My first tweet")
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet1)

    [{_key, tweet1}] = Enum.take(tweet_list.tweets, 1)

    {:ok, tweet_list} = TweetLog.delete_tweet(tweet_list, tweet1)
    [{_key, tweet1}] = Enum.take(tweet_list.tweets, 1)
    assert tweet1.content =~ ""
  end

  test "get the last posted tweet", state do
    tweet_list = state[:tweet_list]

    tweet1 = Tweet.new("My first tweet")
    tweet2 = Tweet.new("My second tweet")

    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet1)
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet2)

    latest_tweet = TweetLog.get_last(tweet_list)
    assert latest_tweet.content =~ tweet2.content
  end

  test "get a specific tweet", state do
    tweet_list = state[:tweet_list]

    tweet1 = Tweet.new("Hello world!")
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet1)

    latest_tweet = TweetLog.get_last(tweet_list)

    {:ok, tweet_by_id} = TweetLog.get_tweet(tweet_list, latest_tweet.id)

    assert tweet_by_id.content =~ tweet1.content
  end

  test "update a tweet after comment", state do
    tweet_list = state[:tweet_list]

    {:ok, user} = User.new("bob@gmail.com", "Bob C.", "bob")
    user = %{user | id: UUID.uuid1()}

    tweet1 = Tweet.new("My first tweet")
    {:ok, tweet_list} = TweetLog.add_tweet(tweet_list, tweet1)
    latest_tweet = TweetLog.get_last(tweet_list)

    {:ok, tweet_with_comment} =
      Tweet.add_comment(latest_tweet, user, "my comment")

    {:ok, tweet_list} =
      TweetLog.update_tweet(tweet_list, tweet_with_comment)

    [{_key, tweet}] = Enum.take(tweet_list.tweets, 1)
    [{_key, comment}] = Enum.take(tweet.comments, 1)
    assert comment.text =~ "my comment"
  end
end
