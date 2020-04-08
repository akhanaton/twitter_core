defmodule TweetLogTest do
  use ExUnit.Case, async: true

  @subject Twitter.Core.TweetLog
  alias Twitter.Core.{Tweet, User}

  setup do
    user = User.new("alice@gmail.com", "Alice B.", "alice")
    user = %{user | id: UUID.uuid1()}
    tweet_list = @subject.new(user)

    [tweet_list: tweet_list, user: user]
  end

  describe "add_tweet/2" do
    test "added tweet should have correct content and timestamp", state do
      tweet_list = state[:tweet_list]
      user = state[:user]
      expected_tweet = Tweet.new("Hello world!")

      {:ok, tweet_list} = @subject.add_tweet(tweet_list, expected_tweet)

      assert tweet_list.user_id == user.id
      assert Enum.count(tweet_list.tweets) == 1

      [{_key, actual_tweet}] = Enum.take(tweet_list.tweets, 1)

      assert %{content: expected_tweet.content, created: expected_tweet.created} == %{
               content: actual_tweet.content,
               created: actual_tweet.created
             }
    end
  end

  describe "all_tweets/1" do
    test "returns a list of tweets where there are tweets", state do
      tweet_list = state[:tweet_list]

      tweet1 = Tweet.new("My first tweet")
      tweet2 = Tweet.new("My second tweet")
      tweet3 = Tweet.new("My third tweet")

      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet2)
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet3)

      assert Enum.count(tweet_list.tweets) == 3

      tweets = @subject.all_tweets(tweet_list)

      assert Enum.count(tweets) == 3
    end

    test "returns an empty list where there are no tweets", state do
      tweet_list = state[:tweet_list]
      expected = []
      actual = @subject.all_tweets(tweet_list)

      assert ^expected = actual
    end
  end

  describe "delete_tweet/2" do
    test "deleted tweet has no content", state do
      tweet_list = state[:tweet_list]

      tweet1 = Tweet.new("My first tweet")
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)

      [{_key, tweet1}] = Enum.take(tweet_list.tweets, 1)

      {:ok, tweet_list} = @subject.delete_tweet(tweet_list, tweet1)
      [{_key, tweet1}] = Enum.take(tweet_list.tweets, 1)
      assert tweet1.content =~ ""
    end

    test "return an error if the tweet does not exist", state do
      tweet_list = state[:tweet_list]

      tweet1 = Tweet.new("My first tweet")
      tweet2 = Tweet.new("My second tweet")

      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)

      expected = {:error, :invalid_delete_operation}
      actual = @subject.delete_tweet(tweet_list, tweet2)

      assert ^expected = actual
    end
  end

  describe "get_last/1" do
    test "returns last created tweet", state do
      tweet_list = state[:tweet_list]

      tweet1 = Tweet.new("My first tweet")
      tweet2 = Tweet.new("My second tweet")

      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet2)

      latest_tweet = @subject.get_last(tweet_list)
      assert latest_tweet.content =~ tweet2.content
    end

    test "return ? where no tweet exist", state do
      tweet_list = state[:tweet_list]

      expected = {:error, :no_tweets}
      actual = @subject.get_last(tweet_list)
      assert ^expected = actual
    end
  end

  describe "get_tweet/2" do
    test "get a specific tweet", state do
      tweet_list = state[:tweet_list]

      tweet1 = Tweet.new("Hello world!")
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)

      latest_tweet = @subject.get_last(tweet_list)

      {:ok, tweet_by_id} = @subject.get_tweet(tweet_list, latest_tweet.id)

      assert tweet_by_id.content =~ tweet1.content
    end

    test "returns an error when tweet not found", state do
      tweet_list = state[:tweet_list]

      expected = {:error, :tweet_not_found}

      actual = @subject.get_tweet(tweet_list, UUID.uuid1())

      assert ^expected = actual
    end
  end

  describe "update_tweet/2" do
    test "update a tweet after comment", state do
      tweet_list = state[:tweet_list]

      user = User.new("bob@gmail.com", "Bob C.", "bob")
      user = %{user | id: UUID.uuid1()}

      tweet1 = Tweet.new("My first tweet")
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)
      latest_tweet = @subject.get_last(tweet_list)

      {:ok, tweet_with_comment} = Tweet.add_comment(latest_tweet, user, "my comment")

      {:ok, tweet_list} = @subject.update_tweet(tweet_list, tweet_with_comment)

      [{_key, tweet}] = Enum.take(tweet_list.tweets, 1)
      [{_key, comment}] = Enum.take(tweet.comments, 1)
      assert comment.text =~ "my comment"
    end

    test "returns an error when tweet to update not found", state do
      tweet_list = state[:tweet_list]

      user = User.new("bob@gmail.com", "Bob C.", "bob")
      user = %{user | id: UUID.uuid1()}

      tweet1 = Tweet.new("My first tweet")
      {:ok, tweet_list} = @subject.add_tweet(tweet_list, tweet1)

      tweet_with_comment = Tweet.new("Tweet with comment")
      tweet_with_comment = %{tweet_with_comment | id: UUID.uuid1()}

      expected = {:error, :tweet_not_found}

      {:ok, tweet_with_comment} = Tweet.add_comment(tweet_with_comment, user, "my comment")
      actual = @subject.update_tweet(tweet_list, tweet_with_comment)

      assert ^expected = actual
    end
  end
end
