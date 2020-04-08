defmodule TimelineTest do
  use ExUnit.Case

  @subject Twitter.Core.Timeline
  alias Twitter.Core.{Tweet, User}

  setup do
    timeline = @subject.new()
    user = User.new("alice@fakemail.fake", "Alice B.", "alice")
    user = %{user | id: UUID.uuid1()}
    tweet = Tweet.new("Hello world!")
    tweet = %{tweet | id: UUID.uuid1(), user_id: user.id}

    [timeline: timeline, user: user, tweet: tweet]
  end

  describe "add/2" do
    test "add a tweet to the timeline", state do
      timeline = state[:timeline]
      user = state[:user]
      tweet = state[:tweet]

      timeline = @subject.add(timeline, tweet)

      assert Enum.count(timeline.tweets) == 1
      tweet_meta = Map.fetch!(timeline.tweets, tweet.id)
      assert tweet_meta.user_id == user.id
      assert tweet.id == tweet_meta.tweet_id
    end

    test "returns an error when tweet id is nil", state do
      timeline = state[:timeline]

      tweet = Tweet.new("Hello world!")

      expected = {:error, :invalid_tweet}
      actual = @subject.add(timeline, tweet)

      assert ^expected = actual
    end

    test "returns an error when user id is nil", state do
      timeline = state[:timeline]

      tweet = Tweet.new("Hello world!")
      tweet = %{tweet | id: UUID.uuid1()}

      expected = {:error, :invalid_user}
      actual = @subject.add(timeline, tweet)

      assert ^expected = actual
    end
  end

  describe "delete/2" do
    test "delete tweet from timeline", state do
      timeline = state[:timeline]
      tweet = state[:tweet]

      timeline = @subject.add(timeline, tweet)

      second_user = User.new("bob@fakemail.fake", "Bob C.", "bob")
      second_user = %{second_user | id: UUID.uuid1()}

      second_tweet = Tweet.new("My second tweet")
      second_tweet = %{second_tweet | id: UUID.uuid1(), user_id: second_user.id}

      timeline = @subject.add(timeline, second_tweet)

      assert Enum.count(timeline.tweets) == 2

      {:ok, timeline} = @subject.delete(timeline, tweet)

      assert assert Enum.count(timeline.tweets) == 1

      tweet_meta = Map.fetch!(timeline.tweets, second_tweet.id)
      assert second_user.id == tweet_meta.user_id
      assert tweet_meta.tweet_id == second_tweet.id
    end

    test "returns an error if tweet does not exist", state do
      timeline = state[:timeline]
      tweet = state[:tweet]
      user = state[:user]

      timeline = @subject.add(timeline, tweet)

      tweet_to_delete = Tweet.new("My second tweet")
      tweet_to_delete = %{tweet_to_delete | id: UUID.uuid1(), user_id: user.id}

      expected = {:error, :tweet_not_found}

      actual = @subject.delete(timeline, tweet_to_delete)
      assert ^expected = actual
    end
  end
end
